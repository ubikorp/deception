Given /^I have disabled notifications$/ do
  @user = User.find_by_login('zapnap') || Factory(:zapnap)
  @user.notify_start         = false
  @user.notify_finish        = false
  @user.notify_period_change = false
  @user.notify_death         = false
  @user.notify_quit          = false
  @user.notify_reply         = false
  @user.save
end

When /^I send a public message containing "([^\"]*)"$/ do |arg1|
  @user = User.find_by_login('zapnap')
  @msg = Factory(:incoming_message, :game => Game.first, :from_user => @user, :text => arg1)
  puts "USER IS A #{@user.active_player.type}"
end

When /^I send a direct message containing "([^\"]*)"$/ do |arg1|
  @user = User.find_by_login('zapnap')
  @msg = Factory(:incoming_message, :game => Game.first, :from_user => @user, :text => arg1)
end

Then /^I should be following the gamebot user on Twitter$/ do
  User.find_by_login('zapnap').should be_following
end

Then /^I should receive a direct message$/ do
  (OutgoingMessage.count.should > 0) && (OutgoingMessage.find(:first, :conditions => { :to_user_id => User.find_by_login('zapnap') }).should_not be_nil)
end

Then /^the direct message should contain "([^\"]*)"$/ do |arg1|
  msgs = OutgoingMessage.find(:all, :conditions => { :to_user_id => User.find_by_login('zapnap') })
  puts msgs.map { |a| a.text }.join(' - ')
  msgs.detect { |m| m.text.match(arg1) }.should_not be_nil
end

Then /^I should not receive a direct message containing "([^\"]*)"$/ do |arg1|
  msgs = OutgoingMessage.find(:all, :conditions => { :to_user_id => User.find_by_login('zapnap') })
  msgs.detect { |m| m.text.match(arg1) }.should be_nil
end
