# == Schema Information
#
# Table name: periods
#
#  id         :integer         not null, primary key
#  game_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Period do
  it { should belong_to(:game) }
  it { should have_many(:events) }

  it { should validate_presence_of(:game_id) }
  
  before(:each) do
    @game = Factory(:game)
    4.times { @game.periods.create }
  end

  it 'should be a night period' do
    @game.periods[0].phase.should == :night
    @game.periods[2].phase.should == :night
  end

  it 'should be a day period' do
    @game.periods[1].phase.should == :day
    @game.periods[3].phase.should == :day
  end

  it 'should be during the first day' do
    @game.periods[0].day.should == 1
    @game.periods[1].day.should == 1
  end

  it 'should be during the second day' do
    @game.periods[2].day.should == 2
    @game.periods[3].day.should == 2
  end

  it 'should be current' do
    Game.any_instance.stubs(:playable?).returns(true)
    @game.periods[2].should_not be_current
    @game.periods.last.should be_current
  end

  it 'should count down time remaining' do
    time = Time.now
    Time.stubs(:now).returns(time)

    @period = @game.periods.last
    @period.time_remaining.should == @period.created_at.utc + @game.period_length - time.utc
  end
end
