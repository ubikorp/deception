require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
  before(:each) do
    @user = Factory.build(:user)
    @obs = UserObserver.instance
  end

  it 'should auto-follow the new user once they authenticate for the first time' do
    GameBot.twitter.expects(:friendship_create).with(@user.login)
    @obs.after_create(@user)
  end
end
