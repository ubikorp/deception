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

describe IncomingMessage do
  include GameSpecHelper

  it { should validate_presence_of(:from_user_id) }
  it { should validate_presence_of(:status_id) }
  it { should validate_uniqueness_of(:status_id) }

  it { should belong_to(:from_user, :class_name => "User") }

  before(:each) do
    IncomingMessage.stubs(:twitter).returns(@twitter = mock('twitter'))
    @message = Factory(:incoming_message)
  end

  context 'replies' do
    it 'should be created' do
      lambda {
        @message.reply("srsly?").should_not be_false
      }.should change(OutgoingMessage, :count)
    end

    it 'should be sent to the correct user' do
      @message.reply("srsly?").to_user.should == @message.from_user
    end
  end

  context 'polling' do
    before(:each) do
      @game = setup_game
    end

    it 'should create new messages from twitter' do
      @replies = [Mash.new({ :id => 20000433, :user => { :screen_name => 'ebloodstone' }, :text => "@gamebot i'm voting to kill @aaronstack because he is jerks" })]
      IncomingMessage.twitter.stubs(:replies).returns(@replies)

      lambda {
        IncomingMessage.receive_messages
      }.should change(IncomingMessage, :count)
    end

    it 'should fail to record messages for inactive players' do
      @replies = [Mash.new({ :id => 20000433, :user => { :screen_name => 'timferriss' }, :text => "@gamebot i'm voting to kill @aaronstack because he is jerks" })]
      IncomingMessage.twitter.stubs(:replies).returns(@replies)

      lambda {
        IncomingMessage.receive_messages
      }.should_not change(IncomingMessage, :count)
    end
  end
end
