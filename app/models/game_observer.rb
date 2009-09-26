class GameObserver < ActiveRecord::Observer
  def before_destroy(game)
    # TODO: separate notification setting for aborted?
    game.players.each do |player|
      GameBot.messages.dm(player.user.login, build_message(:game_abort)) if player.user.notify_finish?
    end
  end

  def after_transition(game, transition)
    case(transition.event)
    when :start
      game.players.each do |player|
        GameBot.messages.dm(player.user.login, build_message(:game_start, player.type)) if player.user.notify_start?
      end
    when :continue
      if period = game.periods[-2] # previous period
        notice = period_change_message(period)

        # don't send messages to dead players here; handled elsewhere
        game.players.alive.each do |player|
          GameBot.messages.dm(player.user.login, notice) if player.user.notify_period_change?
        end

        send_death_notice(period.events.kills.first) if game.events.kills.length > 0 # assume single death in a period
      end
    when :finish
      send_death_notice(game.events.kills.last) if game.events.kills.length > 0 # send final kill notice (last round)

      game.players.each do |player|
        GameBot.messages.dm(player.user.login, build_message("game_over_#{game.winner_type}")) if player.user.notify_finish?
      end
    end
  end

  private

  # TODO: move this to an observer on KillEvent instead?
  def send_death_notice(event)
    player = event.target_player
    if player.user.notify_death?
      notice = if (event.period.phase == :night)
        build_message(:death_villager_am)
      else # game.night?
        build_message("death_#{player.type}_pm")
      end

      GameBot.messages.dm(player.user.login, notice)
    end
  end

  def period_change_message(period)
    # TODO: include suicide notifications (separate notification setting too?)
    # quits = period.events.quits

    kills = period.events.kills

    if kills.length > 0
      victim = kills[0].target_player # assuming a singular victim for now

      if period.game.day?
        build_message(:period_summary_am, victim.user.login) + build_message(:period_change_am)
      else # period.game.night?
        build_message(:period_summary_pm, victim.user.login) + build_message("#{victim.type}_lynch") + build_message(:period_change_pm)
      end
    else
      if period.game.day?
        build_message(:period_nodeath_am) + build_message(:period_change_am)
      else
        build_message(:period_nodeath_pm) + build_message(:period_change_pm)
      end
    end
  end

  def build_message(*args)
    DeceptionGame::Messages.build(*args)
  end
end
