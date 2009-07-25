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

Then /^I should receive a direct message$/ do
  OutgoingMessage.count.should == 1
  OutgoingMessage.last.to_user.login.should == 'zapnap'
end

Then /^The direct message should contain "([^\"]*)"$/ do |arg1|
  OutgoingMessage.last.text.should match(/#{arg1}/)
end
