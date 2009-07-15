Given /^I am already participating in a game$/ do
  @game   = Factory(:game, :owner => User.last)
  @player = Factory(:villager, :user => User.last, :game => @game)
end

Given /^there is a game called "([^\"]*)"$/ do |arg1|
  @game = Factory(:game, :name => arg1, :owner => Factory(:user))
end
