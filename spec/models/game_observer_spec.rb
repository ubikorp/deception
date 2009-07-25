require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe GameObserver do
  include GameSpecHelper

  before(:each) do
    setup_game(false) # setup but don't start
    @obs = GameObserver.instance
  end

  it 'should broadcast a game start notice when the game begins' do
    lambda { 
      @game.start
      @obs.after_transition(@game, mock('Transition', :event => :start))
    }.should change(OutgoingMessage, :count)

    msg = OutgoingMessage.last
    msg.text.should match(/game has started/)
  end

  it 'should broadcast a game over notice when the game ends' do
    lambda {
      @game.start
      @game.finish
      @obs.after_transition(@game, mock('Transition', :event => :finish))
    }.should change(OutgoingMessage, :count)

    msg = OutgoingMessage.last
    msg.text.should match(/end of the game/)
  end

  context 'death notice' do
    before(:each) do
      @game.start
    end

    it 'should be sent to werewolf victims at sunrise' do
      lambda {
        @wolf.user.vote(@p1.user)
        @game.continue # day -> night
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.last
      msg.to_user.should == @p1.user
      msg.text.should match(/#{DeceptionGame::Messages::DEATH_VILLAGER_AM_MSG}/)
    end

    it 'should be sent to villager lynching victims at sunset' do
      @game.continue # night -> day

      lambda {
        @p1.user.vote(@p2.user)
        @wolf.user.vote(@p2.user)
        @game.continue # day -> night
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.find(:first, :conditions => { :to_user_id => @p2.user_id })
      msg.text.should match(/#{DeceptionGame::Messages::DEATH_VILLAGER_PM_MSG}/)
    end

    it 'should be sent to werewolf when villagers lynch them' do
      @game.continue # night -> day

      lambda {
        @p1.user.vote(@wolf.user)
        @p2.user.vote(@wolf.user)
        @game.continue # day -> night
        @obs.after_transition(@game, mock('Transition', :event => :finish))
        # NOTE: this will need updating if we support > 1 werewolf
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.find(:first, :conditions => { :to_user_id => @wolf.user_id })
      msg.text.should match(/#{DeceptionGame::Messages::DEATH_WEREWOLF_PM_MSG}/)
    end

    it 'should not be sent to players with notifications turned off' do
      @p1.user.update_attribute(:notify_death, false)
      @wolf.user.vote(@p1.user)
      @game.continue
      @obs.after_transition(@game, mock('Transition', :event => :continue))
      OutgoingMessage.find(:first, :conditions => { :to_user_id => @p1.user_id }).should be_nil
    end
  end

  context 'period change notice' do
    before(:each) do
      @game.start
    end

    it 'should be sent at sunrise' do
      lambda {
        @game.continue # night -> day
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.last
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_NODEATH_AM_MSG}/)
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_CHANGE_AM_MSG}/)
    end

    it 'should be sent at sunset' do
      @game.continue # night -> day

      lambda {
        @game.continue # day -> night
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.last
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_NODEATH_PM_MSG}/)
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_CHANGE_PM_MSG}/)
    end

    it 'should include werewolf attack results' do
      lambda {
        @wolf.user.vote(@p1.user)
        @game.continue # night -> day
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.find(:first, :conditions => { :to_user_id => @p2.user }, :order => "created_at DESC")
      msg.text.should match(/#{DeceptionGame::Messages.build(:period_summary_am, @p1.user.login)}/)
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_CHANGE_AM_MSG}/)
    end

    it 'should include villager lynching results' do
      @game.continue # night -> day

      lambda {
        @p1.user.vote(@p2.user)
        @wolf.user.vote(@p2.user)
        @game.continue # day -> night
        @obs.after_transition(@game, mock('Transition', :event => :continue))
      }.should change(OutgoingMessage, :count)

      msg = OutgoingMessage.first
      msg.text.should match(/#{DeceptionGame::Messages.build(:period_summary_pm, @p2.user.login)}/)
      msg.text.should match(/#{DeceptionGame::Messages.build(:villager_lynch)}/)
      msg.text.should match(/#{DeceptionGame::Messages::PERIOD_CHANGE_PM_MSG}/)
    end

    it 'should not be sent to dead players' do
      @wolf.user.vote(@p1.user)
      @game.continue # night -> day
      @obs.after_transition(@game, mock('Transition', :event => :continue))

      # should get death notice but not period change notice
      OutgoingMessage.find(:first, :conditions => { :to_user_id => @p1.user_id }).text.should_not match(/#{DeceptionGame::Messages::PERIOD_CHANGE_PM_MSG}/)
    end

    it 'should not be sent to players with notifications turned off' do
      @p1.user.update_attribute(:notify_period_change, false)
      @game.continue # night -> day
      @obs.after_transition(@game, mock('Transition', :event => :continue))
      OutgoingMessage.find(:first, :conditions => { :to_user_id => @p1.user_id }).should be_nil
    end
  end
end
