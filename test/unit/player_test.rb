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
#

require 'test_helper'

class PlayerTest < ActiveSupport::TestCase
  setup do
    @player = Factory(:villager)
  end

  should_belong_to :user
  should_belong_to :game

  should_validate_presence_of :user_id, :game_id
  should_validate_uniqueness_of :user_id, :scoped_to => :game_id
end
