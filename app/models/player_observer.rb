class PlayerObserver < ActiveRecord::Observer
  # auto-start game after max players have joined
  def after_create(player)
    player.game.real_time.event! :player_joined, :user_id => player.user_id, :user => player.user.login
    if player.game.setup? && player.game.startable? && player.game.full?
      logger.info "Auto-Starting Game [#{player.game.id}]"
      player.game.ready
    end
  end
end
