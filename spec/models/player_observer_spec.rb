require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Player do
  include GameSpecHelper

  before(:each) do
    @game = setup_game(false)
    @obs = PlayerObserver.instance
  end

  it 'should auto-start game if minimum players have been met' do
    @game.stubs(:startable?).returns(true)
    @game.stub_chain(:players, :length).returns(5)
    @game.stubs(:max_players).returns(5)

    @game.expects(:ready).returns(true)
    player = Factory.build(:player, :game => @game)
    @obs.after_create(player)
  end
end
