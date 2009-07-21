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
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IncomingMessage do
  it { should validate_presence_of(:from_user_id) }

  it { should belong_to(:from_user, :class_name => "User") }

  before(:all) do
    IncomingMessage.stubs(:twitter).returns(@twitter = mock('twitter'))
  end

  context 'polling' do
    it 'should retrieve new messages from twitter' do
      pending
    end
  end
end
