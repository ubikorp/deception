class GameObserver < ActiveRecord::Observer
  # TODO: come up with a better abstraction for messages
  def after_transition(game, transition)
    case(transition.event)
    when :start
      send_start_notice(game)
    when :continue
      if period = game.periods[-2] # previous period
        send_period_change_notice(game, period)
      end
    when :finish
      send_finish_notice(game)
    end
  end

  private

  def send_start_notice(game)
    game.players.each do |player|
      if player.user.notify_start?
        # TODO: send role assignment with game start message (individual messages instead of broadcast)
        game.outgoing_messages.create(:to_user => player.user, :text => DeceptionGame::Messages.build(:game_start))
      end
    end
  end

  def send_period_change_notice(game, period)
    kills = period.events.kills
    quits = period.events.quits

    game.players.alive.each do |player|
      if player.user.notify_period_change?
        if kills.length > 0
          # assuming a singular victim for now; may not always be the case?
          victim = kills[0].target_player

          # NOTE: don't send messages to dead players
          # players that were just killed are notified post-kill-event
          notice = if game.day?
            DeceptionGame::Messages.build(:period_summary_am, victim.user.login) + DeceptionGame::Messages.build(:period_change_am)
          else # game.night?
            DeceptionGame::Messages.build(:period_summary_pm, victim.user.login) + DeceptionGame::Messages.build("#{victim.type}_lynch") + DeceptionGame::Messages.build(:period_change_pm)
          end
        else
          notice = if game.day?
            DeceptionGame::Messages.build(:period_nodeath_am) + DeceptionGame::Messages.build(:period_change_am)
          else
            DeceptionGame::Messages.build(:period_nodeath_pm) + DeceptionGame::Messages.build(:period_change_pm)
          end
        end

        # TODO: add suicide notices and notification settings for suicides
        game.outgoing_messages.create(:to_user => player.user, :text => notice)
      end
    end

    kills.each { |kill| send_death_notice(kill) }
  end

  def send_death_notice(event)
    player = event.target_player
    if player.user.notify_death?
      notice = if (event.period.phase == :night)
        DeceptionGame::Messages.build(:death_villager_am)
      else # game.night?
        DeceptionGame::Messages.build("death_#{player.type}_pm")
      end

      event.game.outgoing_messages.create(:to_user => player.user, :text => notice)
    end
  end

  def send_finish_notice(game)
    send_death_notice(game.events.kills.last) if game.events.kills.length > 0 # send final kill notice (last round)

    game.players.each do |player|
      if player.user.notify_finish?
        game.outgoing_messages.create(:to_user => player.user, :text => DeceptionGame::Messages.build(:game_over))
      end
    end
  end
end
