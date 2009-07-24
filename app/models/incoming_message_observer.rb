class IncomingMessageObserver < ActiveRecord::Observer
  def after_create(msg)
    if msg.text.match(/kill/i) || msg.text.match(/vote/i)
      vote_message_received(msg)
    elsif msg.text.match(/quit/i)
      quit_message_received(msg)
    else
      help_message_received(msg)
    end
  end

  private

  def vote_message_received(msg)
    if match = msg.text.match(/^.*@(\w+).*$/)
      target_user = User.find_by_login(match[1])
      if target_user && (vote = msg.from_user.vote(target_user))
        logger.info("Created a VoteEvent from msg (@#{msg.from_user.login}): #{msg.text}")
        msg.reply("We've recorded your vote. Thanks!")
      else
        logger.error("Unable to create VoteEvent from msg (@#{msg.from_user.login}): #{msg.text}")
        msg.reply("Can't record this vote. Are you and the target player both playing in the game? Please visit the website for more info.")
      end
    else
      help_message_received(msg)
    end
  end

  def quit_message_received(msg)
    msg.reply("If you want to quit, please visit the web interface!")
  end

  def help_message_received(msg)
    logger.info("Not sure what to do with this msg (@#{msg.from_user.login}): #{msg.text}")
    msg.reply("I don't understand. Do you want to *vote* or *kill* someone? For more info, visit http://mysite.tld")
  end
end
