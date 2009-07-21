# == Schema Information
#
# Table name: messages
#
#  id           :integer         not null, primary key
#  game_id      :integer
#  text         :string(255)
#  delivered_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  type         :string(255)
#  from_user_id :integer
#  to_user_id   :integer
#  status_id    :integer
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  it { should belong_to(:game) }

  it { should validate_presence_of(:text) }
  it { should validate_presence_of(:game_id) }

  before(:each) do
    Twitter::HTTPAuth.stubs(:new).returns(auth = mock('auth'))
    Twitter::Base.stubs(:new).returns(@twitter = mock('twitter'))
  end

  it 'should set up the twitter message handler' do
    Message.twitter.should == @twitter
  end
end
