require 'test_helper'

class GameScriptTest < ActionController::IntegrationTest
  context 'scenarios' do
    setup do
      create_game
    end

    should 'be won by werewolf' do
      # 1. night: werewolf kills villager one
      @nick.vote(@jeff)
      @game.continue
      assert !@jeff.reload.active_player

      # 2. day: villagers vote to lynch villager two
      @nick.vote(@darcy)
      @darcy.vote(@nick)
      @aaron.vote(@darcy)
      @elsa.vote(@aaron)
      @game.continue
      assert !@darcy.reload.active_player

      # 3. night: werewolf kills villager three
      @nick.vote(@aaron)
      @game.continue
      assert !@aaron.reload.active_player

      # 4. day: stalemated voting, nobody gets lynched
      assert_no_difference 'KillEvent.count' do
        @nick.vote(@elsa)
        @elsa.vote(@nick)
        @game.continue
      end

      # 5. night: werewolf kills villager four, wins
      @nick.vote(@elsa)
      @game.continue
      assert !@elsa.reload.active_player
      
      assert @game.finished?
      assert @game.winner.include?(@nick.players.last)

      # game is finished, no players are active
      assert !@nick.reload.active_player
    end

    should 'be won by villagers' do
      # 1. night: werewolf kills villager four
      @nick.vote(@elsa)
      @game.continue
      assert !@elsa.reload.active_player

      # 2. day: villagers vote to lynch werewolf
      @nick.vote(@aaron)
      @jeff.vote(@nick)
      @darcy.vote(@nick)
      @aaron.vote(@darcy)
      @game.continue
      assert !@nick.reload.active_player

      assert @game.finished?
      assert @game.winner.include?(@jeff.players.last)
    end
  end

  def create_game
    @game  = Factory(:game)
    @nick  = Factory(:nick)
    @jeff  = Factory(:jeff)
    @darcy = Factory(:darcy)
    @aaron = Factory(:aaron)
    @elsa  = Factory(:elsa)

    @nick.join(@game, :werewolf)
    @jeff.join(@game)
    @darcy.join(@game)
    @aaron.join(@game)
    @elsa.join(@game)

    @game.start
  end
end
