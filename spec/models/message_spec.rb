# == Schema Information
#
# Table name: messages
#
#  id           :integer         not null, primary key
#  game_id      :integer
#  target       :string(255)
#  text         :string(255)
#  delivered_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  it { should belong_to(:game) }

  it { should have_scope(:delivered, :conditions => "delivered_at IS NOT NULL") }
  it { should have_scope(:undelivered, :conditions => "delivered_at IS NULL") }

  # it { should validate_presence_of(:target) }
  it { should validate_presence_of(:text) }
  it { should validate_presence_of(:game_id) }

  before(:all) do
    Twitter::HTTPAuth.stubs(:new).returns(auth = mock('auth'))
    Twitter::Base.stubs(:new).returns(@twitter = mock('twitter'))
  end

  it 'should be marked as sent' do
    @message = Factory(:message)
    @message.delivered!
    @message.delivered_at.should_not be_nil
  end

  it 'should set up the twitter message handler' do
    Twitter::Base.expects(:new).returns(@twitter = mock('twitter'))
    Message.initialize_twitter.should == @twitter
  end

  context 'delivery' do
    it 'should be sent and marked as delivered' do
      @message = Factory(:message, :delivered_at => nil)
      Message.twitter.expects(:direct_message_create)
      Message.send_messages
      @message.reload.delivered_at.should_not be_nil
    end

    it 'should be broadcast to all active players in the specified game' do
      @game = Factory(:game)
      Factory(:nick).join(@game)
      Factory(:jeff).join(@game)
      Factory(:darcy).join(@game)
      @message = Factory(:message, :text => 'Broadcast message!', :target => nil, :game => @game)
      Message.twitter.expects(:direct_message_create).times(3)
      Message.send_messages
      @message.reload.delivered_at.should_not be_nil
    end
  end
end
