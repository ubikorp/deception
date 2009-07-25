When /^I send a public message containing "([^\"]*)"$/ do |arg1|
  @user = User.find_by_login('zapnap')
  @msg = Factory(:incoming_message, :game => Game.first, :from_user => @user, :text => arg1)
end

When /^I send a direct message containing "([^\"]*)"$/ do |arg1|
  @user = User.find_by_login('zapnap')
  @msg = Factory(:incoming_message, :game => Game.first, :from_user => @user, :text => arg1)
end

Then /^I should be following the gamebot user on Twitter$/ do
  User.find_by_login('zapnap').should be_following
end

Then /^I should receive a notification with my role$/ do
  if @msg = OutgoingMessage.last
    (@msg.to_user.login.should == 'zapnap') && (@msg.text.should match(/has started/))
  else
    false
  end
end

Then /^I should receive a notification that the game has been aborted$/ do
  if @msg = OutgoingMessage.last
    (@msg.to_user.login.should == 'zapnap') && (@msg.text.should match(/has been aborted/))
  else
    false
  end
end

Then /^I should receive a direct message containing "([^\"]*)"$/ do |arg1|
  if @msg = OutgoingMessage.last
    (@msg.to_user.login.should == 'zapnap') && (@msg.text.should match(/#{arg1}/))
  else
    false
  end
end
