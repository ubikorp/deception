# == Schema Information
#
# Table name: games
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class GameTest < ActiveSupport::TestCase
  setup do
    @game = Factory(:game)
  end

  should_validate_presence_of :name
end
