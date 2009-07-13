# == Schema Information
#
# Table name: invitations
#
#  id            :integer         not null, primary key
#  game_id       :integer
#  twitter_login :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

require File.dirname(__FILE__) + '/../spec_helper'

describe Invitation do
  before(:each) do
    Factory(:invitation)
  end

  it { should belong_to(:game) }

  it { should validate_presence_of(:game_id, :twitter_login) }
  it { should validate_uniqueness_of(:twitter_login, :scope => :game_id) }
end
