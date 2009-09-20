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

  it 'should be finished if time is up' do
    time = Time.now
    Time.stubs(:now).returns(time)
    period = @game.periods.last

    period.game.players.stubs(:alive).returns(Array.new(3, mock('Player')))

    period.stubs(:created_at).returns(time - 10)
    period.should_not be_finished

    period.game.stubs(:period_length).returns(5)
    period.should be_finished
  end

  it 'should be finished if all votes are in' do
    time = Time.now
    Time.stubs(:now).returns(time)
    period = @game.periods.last

    period.stubs(:created_at).returns(time - 10)
    period.game.stubs(:period_length).returns(5)

    period.game.players.stubs(:alive).returns(Array.new(3, mock('Player')))
    period.events.stubs(:votes).returns(Array.new(3, mock('Vote')))
    period.should be_finished
  end

  it 'should count down time remaining' do
    time = Time.now
    Time.stubs(:now).returns(time)

    @period = @game.periods.last
    @period.time_remaining.should == @period.created_at.utc + @game.period_length - time.utc
  end
end
