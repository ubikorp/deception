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

describe VoteEvent do
  include GameSpecHelper

  before(:each) do
    @game  = setup_game
    @event = Factory(:vote_event, :period => @game.current_period, :source_player => werewolf, :target_player => villager(0))
  end

  it { should validate_presence_of(:source_player_id) }
  it { should validate_presence_of(:target_player_id) }
  # it { should validate_uniqueness_of(:source_player_id, :scope => :period_id) }

  it 'should overwrite previous votes from the same player in a given period' do
    lambda {
      Factory(:vote_event, :period => @game.current_period, :source_player => werewolf, :target_player => villager(1))
    }.should_not change(VoteEvent, :count)
  end
end
