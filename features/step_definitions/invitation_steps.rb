Given /^I have an invite for "([^\"]*)"$/ do |arg1|
  @game = Game.find_by_name(arg1)
  @game.invitations.create(:twitter_login => 'zapnap')
end

Then /^an invitation for "([^\"]*)" should be sent to "([^\"]*)"$/ do |arg1, arg2|
  @game = Game.find_by_name(arg1)
  @game.invitations.map { |i| i.twitter_login }.should include(arg2)
end
