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
end
