module GamesHelper
  def playing_in_game(game)
    logged_in? && game.players.include?(current_user.active_player)
  end

  def can_be_aborted(game)
    logged_in? && (game.owner == current_user) && game.setup?
  end
end
