Then /^an invitation for "([^\"]*)" should be sent to "([^\"]*)"$/ do |arg1, arg2|
  @game = Game.find_by_name(arg1)
  @game.invitations.map { |i| i.user.login }.should include(arg2)
end
