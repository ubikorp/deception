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

describe Event do
  include GameSpecHelper

  before(:each) do
    @game  = setup_game
    @event = Factory.build(:vote_event, :period => @game.current_period, :source_player => werewolf, :target_player => villager(0))
  end

  it { should belong_to(:period) }
  it { should belong_to(:source_player) }
  it { should belong_to(:target_player) }

  it { should have_scope(:quits, :conditions => { :type => 'QuitEvent' }) }
  it { should have_scope(:kills, :conditions => { :type => 'KillEvent' }) }
  it { should have_scope(:votes, :conditions => { :type => 'VoteEvent' }) }

  it { should validate_presence_of(:period_id) }

  it 'should be related to a game' do
    @event.period.game.should == @event.game
  end

  it 'should be valid' do
    @event.should be_valid
  end

  it 'should make sure that game state is playable' do
    @game.finish
    @event = Factory.build(:vote_event, :period => @game.current_period, :source_player => werewolf, :target_player => villager(0))
    @event.should_not be_valid
    @event.errors.on(:period_id).should include("is not playable")
  end

  it 'should make sure source player is alive' do
    werewolf.update_attribute(:dead, true)
    @event.should_not be_valid
    @event.errors.on(:source_player_id).should include("is not playing in this game")
  end
end
