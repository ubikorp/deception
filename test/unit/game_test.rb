require 'test_helper'

class GameTest < ActiveSupport::TestCase
  setup do
    @game = Factory(:game)
  end

  should_validate_presence_of :name
end
