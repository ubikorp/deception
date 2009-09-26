require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GameObserver do
  include GameSpecHelper

  before(:each) do
    @game = setup_game(false) # setup but don't start
    @obs = GameObserver.instance
  end

  it 'should broadcast a game start notice when the game begins' do
    GameBot.messages.expects(:dm).at_least_once
    GameBot.messages.expects(:dm).with(anything, regexp_matches(/game has started/))

    @game.start
    @obs.after_transition(@game, mock('Transition', :event => :start))
  end

  it 'should broadcast a game over notice when the game ends' do
    GameBot.messages.expects(:dm).at_least_once
    GameBot.messages.expects(:dm).with(anything, regexp_matches(/end of the game/))

    @game.start
    @game.continue
    @event = Factory(:kill_event, :period => @game.current_period, :target_player => werewolf)
    @game.continue # finish, wolf is dead!
    @obs.after_transition(@game, mock('Transition', :event => :finish))
  end

  it 'should broadcast a game cancellation notice if game is aborted' do
    GameBot.messages.expects(:dm).at_least_once
    GameBot.messages.expects(:dm).with(anything, regexp_matches(/has been cancelled/))

    @game.destroy
    @obs.before_destroy(@game)
  end

  context 'death notice' do
    before(:each) do
      @game.start
    end

    it 'should be sent to werewolf victims at sunrise' do
      GameBot.messages.expects(:dm).at_least_once
      GameBot.messages.expects(:dm).with(villager(0).user.login, regexp_matches(/#{DeceptionGame::Messages::DEATH_VILLAGER_AM_MSG}/))

      werewolf.user.vote(villager(0).user)
      @game.continue # day -> night
      @obs.after_transition(@game, mock('Transition', :event => :continue))
    end

    it 'should be sent to villager lynching victims at sunset' do
      GameBot.messages.expects(:dm).at_least_once
      GameBot.messages.expects(:dm).with(villager(1).user.login, regexp_matches(/#{DeceptionGame::Messages::DEATH_VILLAGER_PM_MSG}/))

      @game.continue # night -> day

      villager(0).user.vote(villager(1).user)
      werewolf.user.vote(villager(1).user)
      @game.continue # day -> night
      @obs.after_transition(@game, mock('Transition', :event => :continue))
    end

    it 'should be sent to werewolf when villagers lynch them' do
      GameBot.messages.expects(:dm).at_least_once
      GameBot.messages.expects(:dm).with(werewolf.user.login, regexp_matches(/#{DeceptionGame::Messages::DEATH_WEREWOLF_PM_MSG}/))

      @game.continue # night -> day

      villager(0).user.vote(werewolf.user)
      villager(1).user.vote(werewolf.user)
      @game.continue # day -> night
      @obs.after_transition(@game, mock('Transition', :event => :finish))
    end

    it 'should not be sent to players with notifications turned off' do
      GameBot.messages.expects(:dm).at_least_once
      GameBot.messages.expects(:dm).with(villager(0).user.login, anything).never

      villager(0).user.update_attribute(:notify_death, false)
      werewolf.user.vote(villager(0).user)
      @game.continue
      @obs.after_transition(@game, mock('Transition', :event => :continue))
    end
  end

  context 'period change notice' do
    before(:each) do
      @game.start
    end

    it 'should be sent at sunrise' do
      GameBot.messages.expects(:dm).with(anything, regexp_matches(/#{DeceptionGame::Messages::PERIOD_NODEATH_AM_MSG}/)).at_least_once

      @game.continue # night -> day
      @obs.after_transition(@game, mock('Transition', :event => :continue))
    end

    it 'should be sent at sunset' do
      GameBot.messages.expects(:dm).with(anything, regexp_matches(/#{DeceptionGame::Messages::PERIOD_NODEATH_PM_MSG}/)).at_least_once

      @game.continue # night -> day
      @game.continue # day -> night
      @obs.after_transition(@game, mock('Transition', :event => :continue))
    end

    it 'should include werewolf attack results' do
      GameBot.messages.expects(:dm).at_least_once
      GameBot.messages.expects(:dm).with(anything, regexp_matches(/#{DeceptionGame::Messages.build(:period_summary_am, villager(0).user.login)}/)).at_least_once

      werewolf.user.vote(villager(0).user)
      @game.continue # night -> day
      @obs.after_transition(@game, mock('Transition', :event => :continue))
    end

    it 'should include villager lynching results' do
      GameBot.messages.expects(:dm).at_least_once
      GameBot.messages.expects(:dm).with(anything, regexp_matches(/#{DeceptionGame::Messages.build(:period_summary_pm, villager(1).user.login)}/)).at_least_once
      # msg.text.should match(/#{DeceptionGame::Messages.build(:villager_lynch)}/)

      @game.continue # night -> day

      villager(0).user.vote(villager(1).user)
      werewolf.user.vote(villager(1).user)
      @game.continue # day -> night
      @obs.after_transition(@game, mock('Transition', :event => :continue))
    end

    it 'should not be sent to dead players' do
      # should get death notice but not period change notice
      GameBot.messages.expects(:dm).at_least_once
      GameBot.messages.expects(:dm).with(villager(0).user.login, regexp_matches(/#{DeceptionGame::Messages::PERIOD_CHANGE_PM_MSG}/)).never

      werewolf.user.vote(villager(0).user)
      @game.continue # night -> day
      @obs.after_transition(@game, mock('Transition', :event => :continue))
    end

    it 'should not be sent to players with notifications turned off' do
      GameBot.messages.expects(:dm).at_least_once
      GameBot.messages.expects(:dm).with(villager(0).user.login, anything).never

      villager(0).user.update_attribute(:notify_period_change, false)
      @game.continue # night -> day
      @obs.after_transition(@game, mock('Transition', :event => :continue))
    end
  end
end
