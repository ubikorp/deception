# == Schema Information
#
# Table name: events
#
#  id             :integer         not null, primary key
#  game_id        :integer
#  source_user_id :integer
#  target_user_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'test_helper'

class EventTest < ActiveSupport::TestCase
  setup do
    @event = Factory(:vote_event)
  end

  should_belong_to :game

  should_validate_presence_of :game_id
end
