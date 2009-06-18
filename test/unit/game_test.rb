# == Schema Information
#
# Table name: games
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  state      :string(255)
#

require 'test_helper'

class GameTest < ActiveSupport::TestCase
  context 'game' do
    should_validate_presence_of :name
    should_have_many :periods
    should_have_many :events, :through => :periods
    should_have_many :players
    should_have_many :users, :through => :players

    setup do
      @game = Factory(:game)
    end

    should 'start out in the initial state' do
      assert_equal 'setup', @game.state
    end

    context 'recently created' do
      setup do
        @game.start
      end

      should 'enter the playable state' do
        assert_equal 'playable', @game.state
      end

      should 'create an initial period' do
        assert_equal 1, @game.periods.length
      end

      should 'start out in the night phase' do
        assert_equal :night, @game.periods.first.phase
      end
    end

    should 'be completed' do
      @game.start
      @game.end
      assert_equal 'completed', @game.state
    end

    context 'in progress' do
      setup do
        @game.start
        @game.continue
      end

      should 'remain in the playable state' do
        assert_equal 'playable', @game.state
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
        player = Factory(:werewolf, :game => @game)
        first_period = @game.periods.first
        first_event = Factory(:event, :period => first_period, :source_player => player)
        new_period = @game.periods.create
        new_event = Factory(:event, :period => new_period, :source_player => player)
        assert @game.current_events.include?(new_event)
        assert !@game.current_events.include?(first_event)
      end

      should 'report villagers that are still in the game' do
        player1 = Factory(:villager, :game => @game, :user => Factory(:jeff))
        player2 = Factory(:villager, :game => @game, :user => Factory(:darcy))
        assert_equal 2, @game.villagers.length
        player2.update_attribute(:dead, true)
        assert_equal 1, @game.villagers.length
      end

      should 'report werewolves that are still in the game' do
        player1 = Factory(:werewolf, :game => @game, :user => Factory(:jeff))
        player2 = Factory(:werewolf, :game => @game, :user => Factory(:darcy))
        assert_equal 2, @game.werewolves.length
        player2.update_attribute(:dead, true)
        assert_equal 1, @game.werewolves.length
      end
    end

    context 'end of turn actions' do
      setup do
        @werewolf = Factory(:werewolf, :game => @game)
        @villager1 = Factory(:villager, :user => Factory(:jeff), :game => @game)
        @villager2 = Factory(:villager, :user => Factory(:darcy), :game => @game)
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
    end
  end
end
