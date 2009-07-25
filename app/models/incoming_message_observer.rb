require 'game_messages'

class IncomingMessageObserver < ActiveRecord::Observer
  def after_create(msg)
    if msg.from_user.notify_reply?
      if msg.text.match(/kill/i) || msg.text.match(/vote/i)
        vote_message_received(msg)
      elsif msg.text.match(/quit/i)
        quit_message_received(msg)
      else
        help_message_received(msg)
      end
    end
  end

  private

  def vote_message_received(msg)
    if match = msg.text.match(/^.*@(\w+).*$/)
      target_user = User.find_by_login(match[1])
      if target_user && (vote = msg.from_user.vote(target_user))
        logger.info("Created a VoteEvent from msg (@#{msg.from_user.login}): #{msg.text}")
        msg.reply(DeceptionGame::Messages.build(:bot_valid_vote_reply))
      else
        logger.error("Unable to create VoteEvent from msg (@#{msg.from_user.login}): #{msg.text}")
        msg.reply(DeceptionGame::Messages.build(:bot_invalid_vote_reply))
      end
    else
      help_message_received(msg)
    end
  end

  def quit_message_received(msg)
    msg.reply(DeceptionGame::Messages.build(:bot_quit_reply))
  end

  def help_message_received(msg)
    logger.info("Not sure what to do with this msg (@#{msg.from_user.login}): #{msg.text}")
    msg.reply(DeceptionGame::Messages.build(:bot_help_reply))
  end
end
