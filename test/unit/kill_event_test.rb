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
      @game   = Factory(:game)
      @period = Factory(:first_period, :game => @game)
      @player = Factory(:werewolf, :game => @game)
    end

    should_validate_presence_of :target_player_id

    should 'kill player' do
      @event = Factory(:kill_event, :period => @period, :target_player => @player)
      assert @player.dead?
    end
  end
end
