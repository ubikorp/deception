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

require File.dirname(__FILE__) + '/../spec_helper'

describe QuitEvent do
  before(:each) do
    @game     = Factory(:game)
    @werewolf = Factory(:werewolf, :game => @game)
    @villager = Factory(:villager, :game => @game)
  end

  it 'should kill player' do
    @game.start
    @event = Factory(:quit_event, :period => @game.current_period, :source_player => @werewolf)
    @werewolf.should be_dead
  end
end
