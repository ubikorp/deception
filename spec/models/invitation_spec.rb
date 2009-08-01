# == Schema Information
#
# Table name: invitations
#
#  id            :integer         not null, primary key
#  game_id       :integer
#  twitter_login :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  invited_by_id :integer
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
  before(:each) do
    Factory(:invitation)
  end

  it { should belong_to(:game) }
  it { should belong_to(:invited_by) }

  it { should validate_presence_of(:game_id, :twitter_login, :invited_by_id) }
  # it { should validate_uniqueness_of(:twitter_login, :scope => :game_id) }
  
  it 'should assume user was invited by game owner if unspecified' do
    invitation = Factory(:invitation, :invited_by => nil)
    invitation.invited_by.should == invitation.game.owner
  end
end
