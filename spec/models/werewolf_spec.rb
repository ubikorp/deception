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
#  dead       :boolean
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Werewolf do
  before(:each) do
    @game  = Factory(:game)
    @wolf1 = Factory(:werewolf, :user => Factory(:user), :game => @game)
    @wolf2 = Factory(:werewolf, :user => Factory(:user), :game => @game)
  end

  it 'should have a peer' do
    @game.expects(:werewolves).returns([@wolf1, @wolf2])
    @wolf1.peer.should == @wolf2
  end

  it 'should not have a peer' do
    @game.expects(:werewolves).returns([@wolf1])
    @wolf1.peer.should be_nil
  end
end
