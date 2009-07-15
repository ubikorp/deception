Given /^I am already participating in a game$/ do
  @game   = Factory(:game, :owner => User.last)
  @player = Factory(:villager, :user => User.last, :game => @game)
end

Given /^there is a game called "([^\"]*)"$/ do |arg1|
  @game = Factory(:game, :name => arg1, :owner => Factory(:user))
end

Given /^that there is a pending game called "([^\"]*)"$/ do |arg1|
  @game = Factory(:game, :name => arg1, :owner => Factory(:user))
end

Given /^that there is a finished game called "([^\"]*)"$/ do |arg1|
  @game  = Factory(:game, :name => arg1, :owner => Factory(:user))
  @jeff  = Factory(:jeff)
  @nick  = Factory(:nick)
  @darcy = Factory(:darcy)

  @jeff.join(@game, :werewolf)
  @nick.join(@game)
  @darcy.join(@game)
  @game.start

  @jeff.vote(@nick)
  @game.continue

  @darcy.vote(@jeff)
  @jeff.vote(@darcy)
  @game.continue

  @jeff.vote(@darcy)
  @game.continue
end

Given /^that there is an ongoing game called "([^\"]*)"$/ do |arg1|
  @game = Factory(:game, :name => arg1, :owner => Factory(:user))
  Factory(:jeff).join(@game, :werewolf)
  Factory(:nick).join(@game)
  Factory(:darcy).join(@game)
  @game.start
end
