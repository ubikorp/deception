module DeceptionGame
  module Messages
    GAME_START_MSG        = "Your werewolf game has started! Please visit http://mysite.tld to view your role assignment and start playing."
    GAME_OVER_MSG         = "That's the end of the game. Congrats to the winners!"

    # PLAYER_SUICIDE_MSG    = "<> couldn't handle the stress and committed suicide."

    PERIOD_NODEATH_AM_MSG = "There were no werewolf attacks last night. "
    PERIOD_SUMMARY_AM_MSG = "Werewolves killed poor <> last night! "

    PERIOD_CHANGE_AM_MSG  = "Now it's day time again. Time for justice. Who will you vote to lynch?"

    PERIOD_NODEATH_AM_MSG = "Villagers couldn't decide who to lynch today. Eek. "
    PERIOD_SUMMARY_PM_MSG = "The villagers have chosen to lynch <>, "

    VILLAGER_LYNCH_MSG    = "a common villager. Oops."
    WEREWOLF_LYNCH_MSG    = "a werewolf!"

    PERIOD_CHANGE_PM_MSG  = "Now, night time approaches. Villagers sleep while wolves hunt..."

    DEATH_VILLAGER_AM_MSG = "Your body was discovered this morning, torn to shreds in your bed chambers. Sorry dude. Better luck next time."
    DEATH_VILLAGER_PM_MSG = "Your fellow villagers seem to think you're a werewolf. They're wrong, of course. But they killed you anyway. Jerks."
    DEATH_WEREWOLF_PM_MSG = "Well, your fellow villagers seem to have found you out. It was fun while it lasted though, right?"

    BOT_HELP_REPLY_MSG         = "Please visit the website at http://mysite.told if you want to quit or change your account notification settings."
    BOT_QUIT_REPLY_MSG         = "I don't understand. Do you want to *vote* or *kill* someone? For more info, visit http://mysite.tld"
    BOT_VALID_VOTE_REPLY_MSG   = "We've recorded your vote. Thanks!"
    BOT_INVALID_VOTE_REPLY_MSG = "Can't record this vote. Are you and the target player both playing in the game? Please visit the website for more info."

    def self.build(msg_sym, *args)
      begin
        msg_name = "#{msg_sym}_msg".upcase
        msg = "DeceptionGame::Messages::#{msg_name}".constantize
        args.each do |var|
          msg = msg.sub('<>', var)
        end
        msg
      rescue NameError
        ''
      end
    end
  end
end
