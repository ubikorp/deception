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

describe OutgoingMessage do
  it { should have_scope(:delivered, :conditions => "delivered_at IS NOT NULL") }
  it { should have_scope(:undelivered, :conditions => "delivered_at IS NULL") }

  it { should belong_to(:to_user, :class_name => "User") }

  before(:each) do
    OutgoingMessage.stubs(:twitter).returns(@twitter = mock('twitter'))
  end

  it 'should be marked as sent' do
    @message = Factory(:outgoing_message)
    @message.delivered!
    @message.delivered_at.should_not be_nil
  end

  context 'delivery' do
    it 'should be sent and marked as delivered' do
      @message = Factory(:outgoing_message, :delivered_at => nil)
      @twitter.expects(:direct_message_create)
      OutgoingMessage.send_messages
      @message.reload.delivered_at.should_not be_nil
    end
  end
end
