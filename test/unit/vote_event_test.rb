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

class VoteEventTest < ActiveSupport::TestCase
  context 'vote event' do
    setup do
      @game     = Factory(:game)
      @period   = Factory(:first_period, :game => @game)
      @villager = Factory(:villager, :game => @game)
      @werewolf = Factory(:werewolf, :game => @game)
      @otherguy = Factory(:villager, :game => @game, :user => Factory(:darcy))
      @event    = Factory(:vote_event, :period => @period, :source_player => @villager, :target_player => @werewolf)
    end

    should_validate_presence_of   :source_player_id
    should_validate_presence_of   :target_player_id
    should_validate_uniqueness_of :source_player_id, :scoped_to => :period_id

    should 'disallow more than one vote from a player during a period' do
      assert_raise ActiveRecord::RecordInvalid, 'Validation failed: Source player has already been taken' do
        Factory(:vote_event, :period => @period, :source_player => @villager, :target_player => @otherguy)
      end
    end
  end
end
