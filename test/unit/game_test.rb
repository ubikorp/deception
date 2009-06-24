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
#

require 'test_helper'

class GameTest < ActiveSupport::TestCase
  context 'game' do
    should_have_many :periods
    should_have_many :events, :through => :periods
    should_have_many :players
    should_have_many :users, :through => :players
    should_have_many :invitations
    should_belong_to :owner

    should_validate_presence_of :name, :owner_id, :min_players, :max_players, :period_length
    should_validate_numericality_of :min_players, :max_players, :period_length
    should_allow_values_for     :min_players,   APP_CONFIG[:min_players], APP_CONFIG[:max_players]
    should_not_allow_values_for :min_players,   APP_CONFIG[:min_players] - 1, APP_CONFIG[:max_players] + 1, :message => "is outside the acceptable range"
    should_allow_values_for     :max_players,   APP_CONFIG[:min_players], APP_CONFIG[:max_players]
    should_not_allow_values_for :max_players,   APP_CONFIG[:min_players] - 1, APP_CONFIG[:max_players] + 1, :message => "is outside the acceptable range"
    should_allow_values_for     :period_length, APP_CONFIG[:min_period_length], APP_CONFIG[:max_period_length]
    should_not_allow_values_for :period_length, APP_CONFIG[:min_period_length] - 1, APP_CONFIG[:max_period_length] + 1, :message => "is outside the acceptable range"

    setup do
      @game = Factory(:game)
    end

    should 'start out in the initial state' do
      assert @game.state?(:setup)
    end

    should 'auto-generate a short code' do
      assert !@game.short_code.nil?
    end

    should 'use short code in url parameters' do
      @game.short_code = 'abcde123'
      assert_equal 'abcde123', @game.to_param
    end

    context 'options' do
      setup do
        Factory(:nick).join(@game, :werewolf)
        Factory(:jeff).join(@game)
        Factory(:darcy).join(@game)
      end

      should 'set invitation strategy' do
        @game.invite_only = true
        @game.min_players = 11
        @game.period_length = 600
        @game.start
        assert @game.invite_only
        assert_equal 11, @game.min_players
      end

      should 'only be set before the game is started' do
        @game.start
        assert_raise GameException::GameInProgress do
          @game.invite_only = true
        end
      end

      should 'use defaults if unspecified' do
        @game = Game.new(:name => "Test Game")
        @game.save
        assert_equal APP_CONFIG[:default_period_length], @game.period_length
        assert_equal APP_CONFIG[:min_players],           @game.min_players
        assert_equal APP_CONFIG[:max_players],           @game.max_players
        assert_equal APP_CONFIG[:invite_only],           @game.invite_only
      end

      should 'enforce use of min- and max-player threshold values' do
        @game = Factory(:game)
        @game.min_players = 3
        @game.max_players = 255

        Factory(:elsa).join(@game)
        assert !@game.start

        assert @game.state?(:setup)
      end
    end

    should 'only be startable if minimum requirements are met' do
      assert !@game.start
      assert !@game.playable?
    end

    context 'recently created' do
      setup do
        Factory(:nick).join(@game, :werewolf)
        Factory(:jeff).join(@game)
        Factory(:darcy).join(@game)
        @game.start
      end

      should 'enter the playable state' do
        assert @game.state?(:playable)
      end

      should 'create an initial period' do
        assert_equal 1, @game.periods.length
      end

      should 'start out in the night phase' do
        assert_equal :night, @game.periods.first.phase
      end

      should 'be finished' do
        @game.finish
        assert @game.state?(:finished)
      end
    end

    context 'in progress' do
      setup do
        @werewolf1 = Factory(:werewolf, :game => @game)
        @werewolf2 = Factory(:werewolf, :game => @game, :user => Factory(:aaron))
        @villager1 = Factory(:villager, :game => @game)
        @villager2 = Factory(:villager, :game => @game, :user => Factory(:darcy))
        @game.start
        @game.continue
      end

      should 'remain in the playable state' do
        assert @game.state?(:playable)
      end

      should 'be nighttime' do
        @game.continue
        assert @game.night?
        assert !@game.day?
      end

      should 'be daytime' do
        assert @game.day?
        assert !@game.night?
      end

      should 'report the current period' do
        last = @game.periods.create
        assert_equal last, @game.current_period
      end

      should 'return all events occurring in the current period' do
        first_event = Factory(:event, :period => @game.current_period, :source_player => @villager1)
        @game.continue
        new_event = Factory(:event, :period => @game.current_period, :source_player => @villager1)
        assert @game.current_events.include?(new_event)
        assert !@game.current_events.include?(first_event)
      end

      should 'report villagers that are still in the game' do
        assert_equal 2, @game.villagers.length
        @villager1.update_attribute(:dead, true)
        assert_equal 1, @game.villagers.length
      end

      should 'report werewolves that are still in the game' do
        assert_equal 2, @game.werewolves.length
        @werewolf1.update_attribute(:dead, true)
        assert_equal 1, @game.werewolves.length
      end
    end

    context 'end of turn actions' do
      setup do
        @werewolf = Factory(:werewolf, :game => @game)
        @villager1 = Factory(:villager, :game => @game)
        @villager2 = Factory(:villager, :game => @game, :user => Factory(:darcy))
        @game.start
      end

      should 'kill werewolf victims at sunrise' do
        vote = Factory(:vote_event, :source_player => @werewolf, :target_player => @villager1, :period => @game.current_period)
        @game.continue
        assert @villager1.reload.dead?
      end

      should 'disregard villager votes during night phase' do
        vote = Factory(:vote_event, :source_player => @villager1, :target_player => @werewolf, :period => @game.current_period)
        vote = Factory(:vote_event, :source_player => @villager2, :target_player => @werewolf, :period => @game.current_period)
        @game.continue
        assert !@werewolf.reload.dead?
      end

      should 'lynch chosen villagers at sunset' do
        @game.continue
        vote = Factory(:vote_event, :source_player => @villager1, :target_player => @werewolf, :period => @game.current_period)
        vote = Factory(:vote_event, :source_player => @villager2, :target_player => @werewolf, :period => @game.current_period)
        @game.continue
        assert @werewolf.reload.dead?
      end

      should 'end game if we have a winner' do
        @game.continue
        vote = Factory(:vote_event, :source_player => @villager1, :target_player => @werewolf, :period => @game.current_period)
        vote = Factory(:vote_event, :source_player => @villager2, :target_player => @werewolf, :period => @game.current_period)
        @game.continue
        assert @game.state?(:finished)
      end
    end

    context 'winner' do
      setup do
        @werewolf  = Factory(:werewolf, :game => @game)
        @villager1 = Factory(:villager, :game => @game)
        @villager2 = Factory(:darcy).join(@game)
        @game.start
      end

      should 'be werewolf' do
        @villager1.update_attribute(:dead, true)
        @villager2.update_attribute(:dead, true)
        assert @game.winner.include?(@werewolf)
      end

      should 'be villagers' do
        @werewolf.update_attribute(:dead, true)
        assert @game.winner.include?(@villager1)
      end

      should 'not be available yet' do
        assert !@game.winner
      end
    end

    context 'period change' do
      setup do
        @game.update_attribute(:period_length, 1200)
        @werewolf =  Factory(:werewolf, :game => @game)
        @villager1 = Factory(:villager, :game => @game)
        @villager2 = Factory(:darcy).join(@game)
        @game.start
      end

      should 'indicate when next period starts' do
        assert_equal Time.now.to_i + @game.period_length, @game.next_period_starts_at.to_i
      end

      should 'ensure that games always start on the XX minute mark (for easy / timely updates)'

      should 'continue any game that has exceeded period length' do
        Time.stubs(:now).returns(@game.next_period_starts_at)

        assert_difference 'Period.count' do
          Game.update_periods
        end
      end

      should 'not affect games that have a longer period length' do
        assert_no_difference 'Period.count' do
          Game.update_periods
        end
      end
    end
  end
end
