require 'test_helper'

class GameScriptTest < ActionController::IntegrationTest
  context 'scenarios' do
    setup do
      @game           = Factory(:game)
      @villager_one   = Factory(:villager, :user => Factory(:darcy), :game => @game)
      @villager_two   = Factory(:villager, :user => Factory(:jeff), :game => @game)
      @villager_three = Factory(:villager, :user => Factory(:aaron), :game => @game)
      @villager_four  = Factory(:villager, :user => Factory(:elsa), :game => @game)
      @werewolf       = Factory(:werewolf, :user => Factory(:nick), :game => @game)
      @game.start
    end

    should 'be won by werewolf' do
      # 1. night: werewolf kills villager one
      Factory(:vote_event, :source_player => @werewolf, :target_player => @villager_one, :period => @game.current_period)
      @game.continue
      assert @villager_one.reload.dead?

      # 2. day: villagers vote to lynch villager two
      Factory(:vote_event, :source_player => @werewolf, :target_player => @villager_two, :period => @game.current_period)
      Factory(:vote_event, :source_player => @villager_two, :target_player => @werewolf, :period => @game.current_period)
      Factory(:vote_event, :source_player => @villager_three, :target_player => @villager_two, :period => @game.current_period)
      Factory(:vote_event, :source_player => @villager_four, :target_player => @villager_three, :period => @game.current_period)
      @game.continue
      assert @villager_two.reload.dead?

      # 3. night: werewolf kills villager three
      Factory(:vote_event, :source_player => @werewolf, :target_player => @villager_three, :period => @game.current_period)
      @game.continue
      assert @villager_three.reload.dead?

      # 4. day: stalemated voting, nobody gets lynched
      assert_no_difference 'KillEvent.count' do
        Factory(:vote_event, :source_player => @villager_four, :target_player => @werewolf, :period => @game.current_period)
        Factory(:vote_event, :source_player => @werewolf, :target_player => @villager_four, :period => @game.current_period)
        @game.continue
      end

      # 5. night: werewolf kills villager four, wins
      Factory(:vote_event, :source_player => @werewolf, :target_player => @villager_four, :period => @game.current_period)
      @game.continue
      assert @villager_four.reload.dead?
      
      assert @game.finished?
      assert @game.winner.include?(@werewolf)
    end

    should 'be won by villagers' do
      # 1. night: werewolf kills villager four
      Factory(:vote_event, :source_player => @werewolf, :target_player => @villager_four, :period => @game.current_period)
      @game.continue
      assert @villager_four.reload.dead?

      # 2. day: villagers vote to lynch werewolf
      Factory(:vote_event, :source_player => @villager_one, :target_player => @werewolf, :period => @game.current_period)
      Factory(:vote_event, :source_player => @villager_two, :target_player => @werewolf, :period => @game.current_period)
      Factory(:vote_event, :source_player => @villager_three, :target_player => @villager_one, :period => @game.current_period)
      Factory(:vote_event, :source_player => @werewolf, :target_player => @villager_three, :period => @game.current_period)
      @game.continue
      assert @werewolf.reload.dead?

      assert @game.finished?
      assert @game.winner.include?(@villager_one)
    end
  end
end
