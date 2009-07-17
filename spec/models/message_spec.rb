require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Message do
  it { should belong_to(:game) }

  it { should validate_presence_of(:target) }
  it { should validate_presence_of(:text) }
  it { should validate_presence_of(:game_id) }

  before(:each) do
    @message = Factory(:message)
  end

  it 'should be marked as sent' do
    @message.delivered!
    @message.delivered_at.should_not be_nil
  end
end
