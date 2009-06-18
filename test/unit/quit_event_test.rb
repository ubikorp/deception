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

class QuitEventTest < ActiveSupport::TestCase
  context 'quit event' do
    setup do
      @game   = Factory(:game)
      @period = Factory(:first_period, :game => @game)
      @player = Factory(:werewolf, :game => @game)
    end

    should 'kill player' do
      @event = Factory(:quit_event, :period => @period, :source_player => @player)
      assert @player.dead?
    end
  end
end
