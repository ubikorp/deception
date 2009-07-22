Given /^I am already participating in a game$/ do
  @game   = Factory(:game, :owner => User.last)
  @player = Factory(:villager, :user => User.last, :game => @game)
end

Given /^there is an ongoing game called "([^\"]*)"$/ do |arg1|
  @game = Factory(:game, :name => arg1, :owner => Factory(:user))
  Factory(:jeffrafter).join(@game, :werewolf)
  Factory(:sutto).join(@game)
  Factory(:ebloodstone).join(@game)
  @game.start
end

Given /^there is a finished game called "([^\"]*)"$/ do |arg1|
  @game  = Factory(:game, :name => arg1, :owner => Factory(:user))
  @jeffrafter  = Factory(:jeffrafter)
  @zapnap  = Factory(:zapnap)
  @sutto = Factory(:sutto)

  @jeffrafter.join(@game, :werewolf)
  @zapnap.join(@game)
  @sutto.join(@game)
  @game.start

  @jeffrafter.vote(@zapnap)
  @game.continue

  @sutto.vote(@jeffrafter)
  @jeffrafter.vote(@sutto)
  @game.continue

  @jeffrafter.vote(@sutto)
  @game.continue
  @game.finish
end

Given /^there is a game called "([^\"]*)"$/ do |arg1|
  @game = Factory(:game, :name => arg1, :owner => Factory(:user))
end

Given /^there is a pending game called "([^\"]*)"$/ do |arg1|
  Given "there is a game called \"#{arg1}\""
end

Given /^there is an invite\-only game called "([^\"]*)"$/ do |arg1|
  @game = Factory(:game, :name => arg1, :owner => Factory(:user), :invite_only => true)
end

Given /^I am the owner of the game called "([^\"]*)"$/ do |arg1|
  @game = Game.find_by_name(arg1)
  @user = User.find_by_login('zapnap')

  @game.owner = @user
  @game.save

  @user.join(@game)
end

Given /^I am playing in the game called "([^\"]*)"$/ do |arg1|
  @game = Game.find_by_name(arg1)
  @user = User.find_by_login('zapnap')
  @user.join(@game)
end

Given /^I am a "([^\"]*)" in the game called "([^\"]*)"$/ do |arg1, arg2|
  @game = Game.find_by_name(arg2)
  @user = User.find_by_login('zapnap')
  @user.join(@game, arg1.to_sym)
end

Given /^"([^\"]*)" is a player in the game called "([^\"]*)"$/ do |arg1, arg2|
  @game = Game.find_by_name(arg2)
  @user = Factory(arg1.to_sym)
  @user.join(@game)
end

Given /^the game called "([^\"]*)" is startable$/ do |arg1|
  @game = Game.find_by_name(arg1)
  APP_CONFIG[:min_players].times { |i| Factory(:user).join(@game) }
end

Given /^the game called "([^\"]*)" is not startable$/ do |arg1|
end

Given /^the game called "([^\"]*)" has started$/ do |arg1|
  Given "the game called \"#{arg1}\" is startable"
  @game.start
end

Given /^the game called "([^\"]*)" is in its "([^\"]*)" period$/ do |arg1, arg2|
  Given "the game called \"#{arg1}\" has started"
  @game.start
  (arg2.to_i - 1).times { |i| @game.continue }
end

Given /^a werewolf killed "([^\"]*)" in the game called "([^\"]*)"$/ do |arg1, arg2|
  @game = Game.find_by_name(arg2)
  @user = User.find_by_login(arg1)
  @werewolf = @game.players.werewolves[0]
  @werewolf.user.vote(@user)
  @game.continue
end

Then /^there should not be a game called "([^\"]*)"$/ do |arg1|
  Game.find_by_name(arg1).should == nil
end

Then /^I should be redirected to the game page for "([^\"]*)"$/ do |arg1|
  @game = Game.find_by_name(arg1)
  response.request.path.should == game_path(@game)
end

Then /^the game called "([^\"]*)" is waiting to start$/ do |arg1|
  @game = Game.find_by_name(arg1)
  @game.should be_ready # manually started, will be promoted to 'start' state by cron task
end

Then /^I should no longer be playing in a game$/ do
  @user = User.find_by_login('zapnap')
  @user.active_player.should be_nil
end

Then /^the vote for "([^\"]*)" has been recorded$/ do |arg1|
  @user = User.find_by_login(arg1)
  VoteEvent.find(:first, :conditions => { :target_player_id => @user.active_player.id }).should_not be_nil
end
