# == Schema Information
#
# Table name: periods
#
#  id         :integer         not null, primary key
#  game_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class PeriodTest < ActiveSupport::TestCase
  should_belong_to :game
  should_have_many :events

  should_validate_presence_of :game_id
  
  context 'game phase' do
    setup do
      @game = Factory(:game)
      4.times { @game.periods.create }
    end

    should 'be a night period' do
      assert_equal :night, @game.periods[0].phase
      assert_equal :night, @game.periods[2].phase
    end

    should 'be a day period' do
      assert_equal :day, @game.periods[1].phase
      assert_equal :day, @game.periods[3].phase
    end
  end
end
