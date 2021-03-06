# == Schema Information
#
# Table name: games
#
#  id            :integer         not null, primary key
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  state         :string(255)
#  invite_only   :boolean
#  min_players   :integer
#  period_length :integer
#  short_code    :string(255)
#  owner_id      :integer
#  max_players   :integer
#  deleted_at    :datetime
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Game do
  include GameSpecHelper

  before(:each) do
    @game = Factory(:game)
  end

  it { should have_many(:periods) }
  it { should have_many(:events, :through => :periods) }
  it { should have_many(:players) }
  it { should have_many(:users, :through => :players) }
  it { should have_many(:invitations) }
  it { should belong_to(:owner) }

  it { should have_scope(:pending,   :conditions => { :state => 'setup', :invite_only => false }, :order => 'created_at DESC') }
  it { should have_scope(:current,   :conditions => { :state => 'playable' }, :order => 'created_at DESC') }
  it { should have_scope(:finished,  :conditions => { :state => 'finished' }, :order => 'created_at DESC') }

  it { should validate_presence_of(:name, :owner_id) } # :min_players, :max_players, :period_length have default values
  it { should validate_numericality_of(:min_players, :max_players, :period_length) }
  it { should validate_inclusion_of(:min_players,    :within => APP_CONFIG[:min_players]..APP_CONFIG[:max_players], :message => "is outside the acceptable range") }
  it { should validate_inclusion_of(:max_players,   :within => APP_CONFIG[:min_players]..APP_CONFIG[:max_players], :message => "is outside the acceptable range") }
  it { should validate_inclusion_of(:period_length, :within => APP_CONFIG[:min_period_length]..APP_CONFIG[:max_period_length], :message => "is outside the acceptable range") }

  it 'should start out in the initial state' do
    @game.state?(:setup).should be_true
  end

  it 'should auto-generate a short code' do
    @game.short_code.should_not be_nil
  end

  #it 'should auto-add the owner of a game as its first player' do
  #  @game.players.length == 1
  #  @game.players[0].user == @game.owner
  #end

  it 'should use short code in url parameters' do
    @game.short_code = 'abcde123'
    @game.to_param.should == 'abcde123'
  end

  it 'should not have any player spots remaining' do
    @game.max_players.times { |i| Factory(:user).join(@game) }
    @game.should be_full
  end

  context 'options' do
    before(:each) do
      Factory(:nick).join(@game, :werewolf)
      Factory(:jeff).join(@game)
      Factory(:darcy).join(@game)
    end

    it 'should set invitation strategy' do
      @game.invite_only = true
      @game.min_players = 11
      @game.period_length = 600
      @game.start
      @game.invite_only.should be_true
      @game.min_players.should == 11
    end

    it 'should only be set before the game is started' do
      @game.start
      lambda {
        @game.invite_only = true
      }.should raise_error(DeceptionGame::Exception::GameInProgress)
    end

    it 'should use defaults if unspecified' do
      @game = Game.new(:name => "Test Game")
      @game.save
      @game.period_length.should == APP_CONFIG[:default_period_length]
      @game.min_players.should == APP_CONFIG[:min_players]
      @game.max_players.should == APP_CONFIG[:max_players]
      @game.invite_only.should == APP_CONFIG[:invite_only]
    end

    it 'should enforce use of min- and max-player threshold values' do
      @game = Factory(:game)
      @game.min_players = 3
      @game.max_players = 255

      Factory(:elsa).join(@game)
      @game.start.should_not be_true
      @game.state?(:setup).should be_true
    end

    it 'should require a period length that is a multiple of the minimum (for easy game turnover sync)' do
      @game.period_length = 930
      @game.should_not be_valid
      @game.errors.on(:period_length).should include("must be a multiple of #{APP_CONFIG[:min_period_length]}")
    end
  end

  it 'should only be startable if minimum requirements are met' do
    @game.ready.should_not be_true
    @game.start.should_not be_true
    @game.should_not be_playable
    @game.errors.on_base.should include("This game must have at least #{APP_CONFIG[:min_players]} players")
  end

  context 'recently created' do
    before(:each) do
      @game = setup_game
    end

    it 'should enter the playable state' do
      @game.state?(:playable).should be_true
    end

    it 'should create an initial period' do
      @game.periods.length.should == 1
    end

    it 'should start out in the night phase' do
      @game.periods.first.phase.should == :night
    end

    it 'should auto-assign roles to players' do
      @game = Factory(:game)
      Factory(:user).join(@game)
      Factory(:user).join(@game)
      Factory(:user).join(@game)
      Factory(:user).join(@game)
      @game.start
      @game.players.map { |a| a.type }.sort.should == ['Villager', 'Villager', 'Villager', 'Werewolf']
    end

    it 'should be finished' do
      @game.finish
      @game.state?(:finished).should be_true
    end
  end

  context 'in progress' do
    before(:each) do
      @game = setup_game
      @game.continue
    end

    it 'should remain in the playable state' do
      @game.state?(:playable).should be_true
    end

    it 'should be nighttime' do
      @game.continue
      @game.night?.should be_true
      @game.day?.should be_false
    end

    it 'should be daytime' do
      @game.day?.should be_true
      @game.night?.should be_false
    end

    it 'should report the current period' do
      last = @game.periods.create
      @game.current_period.should == last
    end

    it 'should return all events occurring in the current period' do
      first_event = Factory(:event, :period => @game.current_period, :source_player => villager(0))
      @game.continue
      new_event = Factory(:event, :period => @game.current_period, :source_player => villager(0))
      @game.current_events.should include(new_event)
      @game.current_events.should_not include(first_event)
    end

    it 'should report villagers that are still in the game' do
      @game.villagers.length.should == 3
      villager(0).update_attribute(:dead, true)
      @game.villagers.length.should == 2
    end
  end

  context 'end of turn actions' do
    before(:each) do
      @game = setup_game
      @game.start
    end

    it 'should kill werewolf victims at sunrise' do
      vote = Factory(:vote_event, :source_player => werewolf, :target_player => villager(0), :period => @game.current_period)
      @game.continue
      villager(0).reload.should be_dead
    end

    it 'should lynch chosen villagers at sunset' do
      @game.continue
      vote = Factory(:vote_event, :source_player => villager(0), :target_player => werewolf, :period => @game.current_period)
      vote = Factory(:vote_event, :source_player => villager(1), :target_player => werewolf, :period => @game.current_period)
      @game.continue
      werewolf.reload.should be_dead
    end

    it 'should end game if we have a winner' do
      @game.continue
      vote = Factory(:vote_event, :source_player => villager(0), :target_player => werewolf, :period => @game.current_period)
      vote = Factory(:vote_event, :source_player => villager(1), :target_player => werewolf, :period => @game.current_period)
      @game.continue
      @game.state?(:finished).should be_true
    end

    it 'should choose a single player to kill if the majority is split' do
      @game.continue

      lambda {
        vote = Factory(:vote_event, :source_player => villager(0), :target_player => villager(2), :period => @game.current_period)
        vote = Factory(:vote_event, :source_player => villager(1), :target_player => villager(2), :period => @game.current_period)
        vote = Factory(:vote_event, :source_player => villager(2), :target_player => werewolf, :period => @game.current_period)
        vote = Factory(:vote_event, :source_player => werewolf, :target_player => werewolf, :period => @game.current_period)
        @game.continue
      }.should change(KillEvent, :count).by(1)
    end
  end

  context 'winner' do
    before(:each) do
      @game = setup_game
      @game.start
    end

    it 'should be werewolf' do
      villager(0).update_attribute(:dead, true)
      villager(1).update_attribute(:dead, true)
      @game.winner.should include(werewolf)
    end

    it 'should be villagers' do
      werewolf.update_attribute(:dead, true)
      @game.winner.should include(villager(0))
    end

    it 'should not be available yet' do
      @game.winner.should be_false
    end

    it 'should summarize results' do
      @game.stubs(:finished?).returns(true)
      werewolf.update_attribute(:dead, true)
      @game.winner_type.should == 'Villagers'
    end
  end

  context 'period change' do
    before(:each) do
      @game = setup_game(false)
      @game.update_attribute(:period_length, 1200)
    end

    it 'should start games that are in the ready state (ensuring that games always start on the XX minute mark for easy sync updates)' do
      @game.ready

      lambda {
        Game.update_periods
        @game.reload.playable?
      }.should change(Period, :count)
    end

    it 'should continue any game whose current period is finished' do
      @game.start
      Period.any_instance.expects(:finished?).returns(true)

      lambda {
        Game.update_periods
      }.should change(Period, :count)
    end

    it 'should not affect games that have a longer period length' do
      @game.start
      lambda {
        Game.update_periods
      }.should_not change(Period, :count)
    end
  end

  context 'invitations' do
    it 'should include an invite for the user' do
      invitation = @game.invitations.create(:twitter_login => 'foobar')
      @game.invitations.for_user(Factory(:user, :login => 'foobar')).should == invitation
    end

    it 'should not include an invite for the user' do
      @game.invitations.for_user(Factory(:user)).should be_nil
    end
  end
end
