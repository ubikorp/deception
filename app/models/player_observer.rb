class PlayerObserver < ActiveRecord::Observer
  # auto-start game after max players have joined
  def after_create(player)
    player.game.ready if player.game.setup? && player.game.startable? && (player.game.players.length == player.game.max_players)
  end
end
