module GameSpecHelper
  def setup_game(start = true)
    @game = Factory(:game)
    @p1   = Factory(:user).join(@game)
    @p2   = Factory(:user).join(@game)
    @p3   = Factory(:user).join(@game)
    @wolf = Factory(:user).join(@game, :werewolf)
    @game.start if start
    @game
  end 

  def werewolf(n = 0)
    @game.players.werewolves[n]
  end 

  def villager(n = 0)
    @game.players.villagers[n]
  end 
end
