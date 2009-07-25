require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IncomingMessage do
  include GameSpecHelper

  before(:each) do
    @obs = IncomingMessageObserver.instance
  end

  it 'should reply to @messages with a helpful direct message' do
    lambda { 
      @msg = Factory.build(:incoming_message, :text => "@gamebot wtf??? random text...")
      @obs.after_create(@msg)
    }.should change(OutgoingMessage, :count)

    reply = OutgoingMessage.last
    reply.to_user.login == @msg.from_user.login
    reply.text.should match(/I don't understand/i)
  end

  it 'should reply to quit messages with further instructions' do
    lambda {
      @msg = Factory.build(:incoming_message, :text => "@gamebot I want to quit")
      @obs.after_create(@msg)
    }.should change(OutgoingMessage, :count)

    reply = OutgoingMessage.last
    reply.to_user.login == @msg.from_user.login
    reply.text.should match(/Please visit the website/i)
  end

  context 'votes' do
    before(:each) do
      setup_game
    end

    it 'should reply to valid vote messages with an acknowledgement' do
      lambda {
        @msg = Factory.build(:incoming_message, :from_user => User.last, :text => "@gamebot I vote for @ebloodstone")
        @obs.after_create(@msg)
      }.should change(OutgoingMessage, :count)

      reply = OutgoingMessage.last
      reply.to_user.login == @msg.from_user.login
      reply.text.should match(/recorded your vote/i)
    end

    it 'should record a vote if message is valid' do
      lambda {
        @msg = Factory.build(:incoming_message, :from_user => User.last, :text => "@gamebot I vote for @ebloodstone")
        @obs.after_create(@msg)
      }.should change(VoteEvent, :count)

      VoteEvent.last.source_player.should == @msg.from_user.active_player
      VoteEvent.last.target_player.should == User.find_by_login('ebloodstone').active_player
    end

    it 'should reply to invalid vote messages' do
      lambda {
        @msg = Factory.build(:incoming_message, :from_user => User.last, :text => "@gamebot I vote for @pedro")
        @obs.after_create(@msg)
      }.should change(OutgoingMessage, :count)

      reply = OutgoingMessage.last
      reply.to_user.login == @msg.from_user.login
      reply.text.should match(/Can't record this vote/i)
    end

    it 'should not record a vote if message is invalid' do
      lambda {
        @msg = Factory.build(:incoming_message, :from_user => User.last, :text => "@gamebot I vote for @pedro")
        @obs.after_create(@msg)
      }.should_not change(VoteEvent, :count)
    end
  end
end
