class PlayerObserver < ActiveRecord::Observer
  # auto-start game after max players have joined
  def after_create(player)
    if player.game.setup? && player.game.startable? && player.game.full?
      logger.info "Auto-Starting Game [#{player.game.id}]"
      player.game.ready
    end
  end
end
