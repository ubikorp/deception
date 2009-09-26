require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Event do
  include GameSpecHelper

  before(:each) do
    @game = setup_game
    @obs = EventObserver.instance
  end

  it 'should continue the game if the period is finished' do
    event = Factory(:vote_event, :period => @game.current_period, :source_player => werewolf, :target_player => villager(0))
    event.period.expects(:finished?).returns(true)
    event.game.expects(:continue).returns(true)

    @obs.after_create(event)
  end
end
