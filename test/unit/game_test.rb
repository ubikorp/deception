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
  should_validate_presence_of :name

  context 'states' do
    setup do
      @game = Factory.build(:game)
    end

    should 'start out in the initial state' do
      assert_equal 'setup', @game.state
    end

    should 'start the game (day first)' do
      @game.start
      assert_equal 'day', @game.state
    end

    should 'end the game' do
      @game.start
      @game.end
      assert_equal 'completed', @game.state
    end

    should 'transition between day and night' do
      @game.start
      @game.continue
      assert_equal 'night', @game.state
      @game.continue
      assert_equal 'day', @game.state
    end
  end
end
