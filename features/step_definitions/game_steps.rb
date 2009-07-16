Given /^I am already participating in a game$/ do
  @game   = Factory(:game, :owner => User.last)
  @player = Factory(:villager, :user => User.last, :game => @game)
end

Given /^there is an ongoing game called "([^\"]*)"$/ do |arg1|
  @game = Factory(:game, :name => arg1, :owner => Factory(:user))
  Factory(:jeff).join(@game, :werewolf)
  Factory(:nick).join(@game)
  Factory(:darcy).join(@game)
  @game.start
end

Given /^there is a finished game called "([^\"]*)"$/ do |arg1|
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
  @game.finish
end

Given /^there is a pending game called "([^\"]*)"$/ do |arg1|
  @game = Factory(:game, :name => arg1, :owner => Factory(:user))
end

Given /^there is an invite\-only game called "([^\"]*)"$/ do |arg1|
  @game = Factory(:game, :name => arg1, :owner => Factory(:user), :invite_only => true)
end

Given /^I am the owner of the game called "([^\"]*)"$/ do |arg1|
  @game = Game.find_by_name(arg1)
  @game.owner = User.find_by_login('zapnap')
  @game.save
end

Then /^there should not be a game called "([^\"]*)"$/ do |arg1|
  Game.find_by_name(arg1).should == nil
end
