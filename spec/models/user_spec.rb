# == Schema Information
#
# Table name: users
#
#  id                           :integer         not null, primary key
#  twitter_id                   :string(255)
#  login                        :string(255)
#  access_token                 :string(255)
#  access_secret                :string(255)
#  remember_token               :string(255)
#  remember_token_expires_at    :datetime
#  name                         :string(255)
#  location                     :string(255)
#  description                  :string(255)
#  profile_image_url            :string(255)
#  url                          :string(255)
#  protected                    :boolean
#  profile_background_color     :string(255)
#  profile_sidebar_fill_color   :string(255)
#  profile_link_color           :string(255)
#  profile_sidebar_border_color :string(255)
#  profile_text_color           :string(255)
#  profile_background_image_url :string(255)
#  profile_background_tiled     :boolean
#  friends_count                :integer
#  statuses_count               :integer
#  followers_count              :integer
#  favourites_count             :integer
#  utc_offset                   :integer
#  time_zone                    :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#

require File.dirname(__FILE__) + '/../spec_helper'

# note: uses TwitterAuth's GenericUser as a base
describe User do
  before(:each) do
    @user = Factory(:darcy)
  end

  it { should have_many(:players) }
  it { should have_many(:games, :through => :players) }
  it { should have_many(:managed_games) }

  it { should validate_presence_of(:login, :twitter_id) }
  it { should validate_uniqueness_of(:login) }
  it { should validate_uniqueness_of(:twitter_id, :message => "ID has already been taken.") }

  context 'invitation' do
    it 'should not exist for game' do
      @game = Factory(:game, :invite_only => true)
      @user.has_invite?(@game).should_not be_true
    end

    it 'should exist for any open game' do
      @game = Factory(:game, :invite_only => false)
      @user.has_invite?(@game).should be_true
    end

    it 'should grant access to game' do
      @game = Factory(:game, :invite_only => true)
      @game.invitations.create(:twitter_login => @user.login)
      @user.has_invite?(@game).should be_true
    end
  end

  context 'joining a game' do
    before(:each) do
      @game = Factory(:game)
    end

    it 'should join a game as a werewolf' do
      @user.join(@game, :werewolf)
      @game.werewolves.should include(@user.players.first)
    end

    it 'should join a game as a villager' do
      @user.join(@game, :villager)
      @game.villagers.should include(@user.players.first)
    end

    it 'should not be allowed to join more than one game at a time' do
      @user.join(@game, :villager)
      @game = Factory(:game)

      lambda {
        @user.join(@other_game, :werewolf).should_not be_true
      }.should_not change(Player, :count)
    end

    it 'should require an invitation' do
      @game = Factory(:game, :invite_only => true)
      @user.join(@game, :werewolf).should_not be_true
    end
  end

  it 'should quit a game in setup phase' do
    @game = Factory(:game)

    lambda {
      @user.join(@game)
      @user.quit(@game)
    }.should_not change(Player, :count)

    @user.active_player.should be_nil
  end

  it 'should quit an in-progress game (with logged quit event)' do
    @game = Factory(:game)
    Factory(:aaron).join(@game)
    Factory(:elsa).join(@game)

    @user.join(@game)
    @game.start

    lambda {
      @user.quit(@game)
      @game.players.should_not include(@user.players.first)
      @game.continue
    }.should change(QuitEvent, :count)
  end

  context 'game status' do
    before(:each) do
      @game1 = Factory(:game)
      @game2 = Factory(:game)
      @p1 = Factory(:nick)
      @p2 = Factory(:jeff)
    end

    it 'should let us know which game is currently active' do
      @player = @user.join(@game1)
      @player.update_attribute(:dead, true)
      @player = @user.join(@game2)

      @user.active_player.should == @player
    end

    it 'should report inactive if user player is dead' do
      @player = @user.join(@game1)
      @player.update_attribute(:dead, true)
      @user.active_player.should_not be_true
    end

    it 'should report inactive if games are finished' do
      @p1.join(@game1, :werewolf)
      @p2.join(@game1)
      @player = @user.join(@game1)
      @game1.start
      @game1.finish
      @user.active_player.should_not be_true
    end
  end

  context 'voting' do
    before(:each) do
      @game   = Factory(:game)
      @target = Factory(:jeff)
      @other  = Factory(:nick)
    end

    it 'should should log a vote for another user' do
      player1 = @user.join(@game, :werewolf)
      player2 = @target.join(@game, :villager)
      @game.start

      lambda {
        @user.vote(@target).should be_true
      }.should change(VoteEvent, :count)
    end

    it 'should fail if user has already voted in this period' do
      player1 = @user.join(@game, :werewolf)
      player2 = @target.join(@game, :villager)
      player3 = @other.join(@game, :villager)
      @game.start
      @user.vote(@target)

      lambda {
        @user.vote(@other).should be_false
      }.should_not change(VoteEvent, :count)
    end

    it 'should fail if user is not an active player' do
      player2 = @target.join(@game, :villager)
      player3 = @other.join(@game, :werewolf)
      @game.start

      lambda {
        @user.vote(@target).should be_false
      }.should_not change(VoteEvent, :count)
    end

    it 'should fail if the target user is not an active player' do
      player1 = @user.join(@game, :werewolf)
      player2 = @target.join(@game, :villager)
      @game.start

      lambda {
        @user.vote(@other).should be_false
      }.should_not change(VoteEvent, :count)
    end
  end
end
