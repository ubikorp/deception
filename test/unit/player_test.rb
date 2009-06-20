# == Schema Information
#
# Table name: players
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  game_id    :integer
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  dead       :boolean
#

require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  context 'player' do
    setup do
      @game     = Factory(:game)
      @werewolf = Factory(:werewolf, :game => @game)
      @villager = Factory(:villager, :game => @game)
      @game.start
    end

    should_belong_to :user
    should_belong_to :game

    should_validate_presence_of :user_id, :game_id
    should_validate_uniqueness_of :user_id, :scoped_to => :game_id

    should 'have to be added to a game during the setup phase' do
      @game = Factory(:game)
      @game.start
      @player = Factory.build(:player, :game => @game)
      assert !@player.valid?
      assert @player.errors.on(:game_id).include?("is already in progress")
    end

    should 'be a werewolf' do
      assert @werewolf.werewolf?
      assert !@werewolf.villager?
    end

    should 'be a villager' do
      assert @villager.villager?
      assert !@villager.werewolf?
    end

    context 'dead players' do
      should 'be dead if they were killed' do
        @event = Factory(:kill_event, :period => @game.current_period, :target_player => @villager)
        assert @villager.dead?
      end

      should 'be dead if they committed suicide' do
        @event = Factory(:quit_event, :period => @game.current_period, :source_player => @villager)
        assert @villager.dead?
      end
    end
  end
end
