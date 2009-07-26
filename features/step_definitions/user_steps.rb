Given /^I am a user named "([^\"]*)"$/ do |arg1|
  @user = User.find_by_login(arg1) || Factory(arg1.to_sym)
end
