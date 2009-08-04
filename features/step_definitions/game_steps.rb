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

Given /^I am the owner of the game$/ do
  @game.owner = @user
  @game.save

  @user.join(@game)
end

Given /^I am a "([^\"]*)" in the game$/ do |arg1|
  role = arg1.match(/player/i) ? nil : arg1.to_sym
  @user.join(@game, role)
end

Given /^"([^\"]*)" is a "([^\"]*)" in the game$/ do |arg1, arg2|
  role = arg2.match(/player/i) ? nil : arg2.to_sym
  user = Factory(arg1.to_sym)
  user.join(@game, role)
end

Given /^the game is startable$/ do
  # make sure minimum number of players is met
  (APP_CONFIG[:min_players] + 1).times { |i| Factory(:user).join(@game) }
end

Given /^the game is not startable$/ do
end

Given /^the game has started$/ do
  Given "the game is startable"
  @game.start
end

Given /^the game is in its "([^\"]*)" period$/ do |arg1|
  Given "the game has started"
  (arg1.to_i - 1).times { |i| @game.continue }
end

Given /^a werewolf killed "([^\"]*)" in the game$/ do |arg1|
  user = User.find_by_login(arg1)
  werewolf = @game.players.werewolves[0]
  werewolf.user.vote(user)
  @game.continue
end

Given /^I have voted to kill "([^\"]*)"$/ do |arg1|
  @user.vote(User.find_by_login(arg1))
end

When /^the game starts$/ do
  @game.start
end

When /^the game is aborted$/ do
  @game.destroy
end

When /^I have been killed in the game$/ do
  @event = KillEvent.create(:period => @game.current_period, :target_player => @user.active_player)
end

When /^the game period turns over$/ do
  @game.continue
end

When /^the game is finished$/ do
  @game.continue
  KillEvent.create(:period => @game.current_period, :target_player => @game.werewolves.first) # hacky
  @game.continue # finish game, werewolf is dead
end

Then /^there should not be a game called "([^\"]*)"$/ do |arg1|
  Game.find_by_name(arg1).should == nil
end

Then /^I should be redirected to the game page for "([^\"]*)"$/ do |arg1|
  @game = Game.find_by_name(arg1)
  response.request.path.should == game_path(@game)
end

Then /^the game is waiting to start$/ do
  @game.reload.should be_ready # manually started, will be promoted to 'start' state by cron task
end

Then /^I should no longer be playing in a game$/ do
  @user.active_player.should be_nil
end

Then /^the vote for "([^\"]*)" has been recorded$/ do |arg1|
  user = User.find_by_login(arg1)
  VoteEvent.find(:first, :conditions => { :target_player_id => user.active_player.id }).should_not be_nil
end

Then /^there is no vote for "([^\"]*)"$/ do |arg1|
  user = User.find_by_login(arg1)
  VoteEvent.find(:first, :conditions => { :target_player_id => user.active_player.id }).should be_nil
end
