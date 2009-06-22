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


require 'test_helper'

# note: uses TwitterAuth's GenericUser as a base
class UserTest < ActiveSupport::TestCase
  context 'user' do
    setup do
      @user = Factory(:darcy)
    end

    should_have_many :players
    should_have_many :games, :through => :players
    should_have_many :managed_games

    should_validate_presence_of :login, :twitter_id
    should_validate_uniqueness_of :login
    should_validate_uniqueness_of :twitter_id, :message => "ID has already been taken."

    context 'invitation' do
      should 'not exist for game' do
        @game = Factory(:game, :invite_only => true)
        assert !@user.has_invite?(@game)
      end

      should 'exist for any open game' do
        @game = Factory(:game, :invite_only => false)
        assert @user.has_invite?(@game)
      end

      should 'grant access to game' do
        @game = Factory(:game, :invite_only => true)
        @game.invitations.create(:twitter_login => @user.login)
        assert @user.has_invite?(@game)
      end
    end

    context 'joining a game' do
      setup do
        @game = Factory(:game)
      end

      should 'join a game as a werewolf' do
        @user.join(@game, :werewolf)
        assert @game.werewolves.include?(@user.players.first)
      end

      should 'join a game as a villager' do
        @user.join(@game, :villager)
        assert @game.villagers.include?(@user.players.first)
      end

      should 'not be allowed to join more than one game at a time' do
        @user.join(@game, :villager)
        @game = Factory(:game)

        assert_no_difference 'Player.count' do
          assert !@user.join(@other_game, :werewolf)
        end
      end

      should 'require an invitation' do
        @game = Factory(:game, :invite_only => true)
        assert !@user.join(@game, :werewolf)
      end
    end

    context 'game status' do
      setup do
        @game1 = Factory(:game)
        @game2 = Factory(:game)
        @p1 = Factory(:nick)
        @p2 = Factory(:jeff)
      end

      should 'let us know which game is currently active' do
        @player = @user.join(@game1)
        @player.update_attribute(:dead, true)
        @player = @user.join(@game2)

        assert_equal @player, @user.active_player
      end

      should 'report inactive if user player is dead' do
        @player = @user.join(@game1)
        @player.update_attribute(:dead, true)
        assert !@user.active_player
      end

      should 'report inactive if games are finished' do
        @p1.join(@game1, :werewolf)
        @p2.join(@game1)
        @player = @user.join(@game1)
        @game1.start
        @game1.finish
        assert !@user.active_player
      end
    end

    context 'voting' do
      setup do
        @game   = Factory(:game)
        @target = Factory(:jeff)
        @other  = Factory(:nick)
      end

      should 'should log a vote for another user' do
        player1 = @user.join(@game, :werewolf)
        player2 = @target.join(@game, :villager)
        @game.start

        assert_difference 'VoteEvent.count' do
          assert @user.vote(@target)
        end
      end

      should 'fail if user has already voted in this period' do
        player1 = @user.join(@game, :werewolf)
        player2 = @target.join(@game, :villager)
        player3 = @other.join(@game, :villager)
        @game.start
        @user.vote(@target)

        assert_no_difference 'VoteEvent.count' do
          assert !@user.vote(@other)
        end
      end

      should 'fail if user is not an active player' do
        player2 = @target.join(@game, :villager)
        player3 = @other.join(@game, :werewolf)
        @game.start

        assert_no_difference 'VoteEvent.count' do
          assert !@user.vote(@target)
        end
      end

      should 'fail if the target user is not an active player' do
        player1 = @user.join(@game, :werewolf)
        player2 = @target.join(@game, :villager)
        @game.start

        assert_no_difference 'VoteEvent.count' do
          assert !@user.vote(@other)
        end
      end
    end
  end
end
