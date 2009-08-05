Given /^I am a user named "([^\"]*)"$/ do |arg1|
  @user = User.find_by_login(arg1) || Factory(arg1.to_sym)
end

Then /^I should be sent "([^\"]*)" notifications$/ do |arg1|
  @user.reload.send("notify_#{arg1}").should be_true
end

Then /^I should not be sent "([^\"]*)" notifications$/ do |arg1|
  @user.reload.send("notify_#{arg1}").should be_false
end
