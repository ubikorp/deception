# == Schema Information
#
# Table name: events
#
#  id               :integer         not null, primary key
#  type             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  source_player_id :integer
#  target_player_id :integer
#  period_id        :integer
#

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  context 'event' do
    setup do
      @game     = Factory(:game)
      @werewolf = Factory(:werewolf, :game => @game)
      @villager = Factory(:villager, :game => @game)

      @game.start
      @event  = Factory.build(:vote_event, :period => @game.current_period, :source_player => @werewolf, :target_player => @villager)
    end

    should_belong_to :period
    should_belong_to :source_player
    should_belong_to :target_player

    should_validate_presence_of :period_id

    should 'be related to a game' do
      assert_equal @event.period.game, @event.game
    end

    should 'be valid' do
      @event.valid?
      assert @event.save
    end

    should 'make sure that game state is playable' do
      @game.finish
      @event = Factory.build(:vote_event, :period => @game.current_period, :source_player => @werewolf, :target_player => @villager)
      assert !@event.valid?
      assert @event.errors.on(:period_id).include?("is not playable")
    end

    should 'make sure source player is alive' do
      @werewolf.update_attribute(:dead, true)
      assert !@event.valid?
      assert @event.errors.on(:source_player_id).include?("is not playing in this game")
    end
  end
end
