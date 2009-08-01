require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Invitation do
  include GameSpecHelper

  before(:each) do
    @obs = InvitationObserver.instance
    User.any_instance.stubs(:twitter).returns(mock('Twitter'))
  end

  it 'should send a direct message after invitation is created' do
    invitation = Factory.build(:invitation)
    invitation.invited_by.twitter.expects(:post)
    @obs.after_create(invitation)
  end
end
