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
      @game = Game.create(:name => 'The Portsmouth Massacre')
    end

    should 'start out in the initial state' do
      assert @game.state?(:setup)
    end

    should 'allow player to join the game' do
      @game.join(Villager.new(:user => Factory(:nick)))
      assert @game.players.length >= 1
      assert !@game.players.first.new_record?
    end

    context 'recently created' do
      setup do
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
    end

    should 'be finished' do
      @game.start
      @game.finish
      assert @game.state?(:finished)
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
        @werewolf = Factory(:werewolf, :game => @game)
        @villager = Factory(:villager, :game => @game)
        @game.start
      end

      should 'be werewolf' do
        @villager.update_attribute(:dead, true)
        assert @game.winner.include?(@werewolf)
      end

      should 'be villagers' do
        @werewolf.update_attribute(:dead, true)
        assert @game.winner.include?(@villager)
      end

      should 'not be available yet' do
        assert !@game.winner
      end
    end
  end
end
