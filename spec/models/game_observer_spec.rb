require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GameObserver do
  include GameSpecHelper

  before(:each) do
    @game = setup_game(false) # setup but don't start
    @obs = GameObserver.instance
  end

  it 'should broadcast a game start notice when the game begins' do
    lambda { 
      @game.start
      @obs.after_transition(@game, mock('Transition', :event => :start))
    }.should change(OutgoingMessage, :count)

    msg = OutgoingMessage.last
    msg.text.should match(/game has started/)
  end

  it 'should broadcast a game over notice when the game ends' do
    lambda {
      @game.start
      @game.continue
      @event = Factory(:kill_event, :period => @game.current_period, :target_player => werewolf)
      @game.continue # finish, wolf is dead!
      @obs.after_transition(@game, mock('Transition', :event => :finish))
    }.should change(OutgoingMessage, :count)

    msg = OutgoingMessage.last
    msg.text.should match(/end of the game/)
  end

  it 'should broadcast a game cancellation notice if game is aborted' do
    lambda {
      @game.destroy
      @obs.before_destroy(@game)
    }.should change(OutgoingMessage, :count)

    msg = OutgoingMessage.last
    msg.text.should match(/has been cancelled/)
  end

  context 'death notice' do
    before(:each) do
      @game.start
    end

    it 'should be sent to werewolf victims at sunrise' do
      lambda {
        werewolf.user.vote(villager(0).user)
        @game.continue # day -> night
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.last
      msg.to_user.should == villager(0).user
      msg.text.should match(/#{DeceptionGame::Messages::DEATH_VILLAGER_AM_MSG}/)
    end

    it 'should be sent to villager lynching victims at sunset' do
      @game.continue # night -> day

      lambda {
        villager(0).user.vote(villager(1).user)
        werewolf.user.vote(villager(1).user)
        @game.continue # day -> night
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.find(:first, :conditions => { :to_user_id => villager(1).user_id })
      msg.text.should match(/#{DeceptionGame::Messages::DEATH_VILLAGER_PM_MSG}/)
    end

    it 'should be sent to werewolf when villagers lynch them' do
      @game.continue # night -> day

      lambda {
        villager(0).user.vote(werewolf.user)
        villager(1).user.vote(werewolf.user)
        @game.continue # day -> night
        @obs.after_transition(@game, mock('Transition', :event => :finish))
        # NOTE: this will need updating if we support > 1 werewolf
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.find(:first, :conditions => { :to_user_id => werewolf.user_id })
      msg.text.should match(/#{DeceptionGame::Messages::DEATH_WEREWOLF_PM_MSG}/)
    end

    it 'should not be sent to players with notifications turned off' do
      villager(0).user.update_attribute(:notify_death, false)
      werewolf.user.vote(villager(0).user)
      @game.continue
      @obs.after_transition(@game, mock('Transition', :event => :continue))
      OutgoingMessage.find(:first, :conditions => { :to_user_id => villager(0).user_id }).should be_nil
    end
  end

  context 'period change notice' do
    before(:each) do
      @game.start
    end

    it 'should be sent at sunrise' do
      lambda {
        @game.continue # night -> day
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.last
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_NODEATH_AM_MSG}/)
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_CHANGE_AM_MSG}/)
    end

    it 'should be sent at sunset' do
      @game.continue # night -> day

      lambda {
        @game.continue # day -> night
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.last
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_NODEATH_PM_MSG}/)
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_CHANGE_PM_MSG}/)
    end

    it 'should include werewolf attack results' do
      lambda {
        werewolf.user.vote(villager(0).user)
        @game.continue # night -> day
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.find(:first, :conditions => { :to_user_id => villager(1).user }, :order => "created_at DESC")
      msg.text.should match(/#{DeceptionGame::Messages.build(:period_summary_am, villager(0).user.login)}/)
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_CHANGE_AM_MSG}/)
    end

    it 'should include villager lynching results' do
      @game.continue # night -> day

      lambda {
        villager(0).user.vote(villager(1).user)
        werewolf.user.vote(villager(1).user)
        @game.continue # day -> night
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.first
      msg.text.should match(/#{DeceptionGame::Messages.build(:period_summary_pm, villager(1).user.login)}/)
      msg.text.should match(/#{DeceptionGame::Messages.build(:villager_lynch)}/)
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_CHANGE_PM_MSG}/)
    end

    it 'should not be sent to dead players' do
      werewolf.user.vote(villager(0).user)
      @game.continue # night -> day
      @obs.after_transition(@game, mock('Transition', :event => :continue))

      # should get death notice but not period change notice
      OutgoingMessage.find(:first, :conditions => { :to_user_id => villager(0).user_id }).text.should_not match(/#{DeceptionGame::Messages::PERIOD_CHANGE_PM_MSG}/)
    end

    it 'should not be sent to players with notifications turned off' do
      villager(0).user.update_attribute(:notify_period_change, false)
      @game.continue # night -> day
      @obs.after_transition(@game, mock('Transition', :event => :continue))
      OutgoingMessage.find(:first, :conditions => { :to_user_id => villager(0).user_id }).should be_nil
    end
  end
end
