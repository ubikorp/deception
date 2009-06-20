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

class KillEventTest < ActiveSupport::TestCase
  context 'kill event' do
    setup do
      @game     = Factory(:game)
      @werewolf = Factory(:werewolf, :game => @game)
      @villager = Factory(:villager, :game => @game)
    end

    should_validate_presence_of :target_player_id

    should 'kill player' do
      @game.start
      @event = Factory(:kill_event, :period => @game.current_period, :target_player => @werewolf)
      assert @werewolf.dead?
    end
  end
end
