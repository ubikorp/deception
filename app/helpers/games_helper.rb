module GamesHelper
  def playing_in_game(game)
    logged_in? && game.players.include?(current_user.active_player)
  end

  def can_be_aborted(game)
    logged_in? && (game.owner == current_user) && game.setup?
  end

  def period_votes_summary(period)
    targets = {}
    period.events.votes.each do |vote|
      target = vote.target_player
      source = vote.source_player
      if targets[target].nil?
        targets[target] = [source]
      else
        targets[target].push(source)
      end
    end

    targets
  end

  def voted_for_player(player)
    if playing_in_game(player.game) && player.game.playable?
      current_user.voted_in(player.game.current_period) == player.user
    else
      false
    end
  end

  def player_profile_link(player)
    link_to(player.user.login, twitter_profile_url(player.user), :target => '_blank')
  end
end
