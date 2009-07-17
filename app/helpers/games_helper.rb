module GamesHelper
  def can_be_aborted(game)
    logged_in? && (game.owner == current_user) && game.setup?
  end
end
