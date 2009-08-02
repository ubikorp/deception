# == Schema Information
#
# Table name: messages
#
#  id           :integer         not null, primary key
#  game_id      :integer
#  text         :string(255)
#  delivered_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  type         :string(255)
#  from_user_id :integer
#  to_user_id   :integer
#  status_id    :integer
#

class IncomingMessage < Message
  belongs_to :from_user, :class_name => "User"

  validates_presence_of :from_user_id, :status_id
  validates_uniqueness_of :status_id

  # poll twitter for new game messages
  # return the number of new messages that were successfully processed
  def self.receive_messages
    # TODO: may need to retrieve multiple pages so we don't miss anything (if interval is too large)
    logger.info("Receiving messages from Twitter...")
    count = 0

    conditions = { :count => 200 }
    conditions[:since_id] = self.last.status_id unless self.last.nil?

    # fetch replies / mentions
    self.twitter.replies(conditions).each do |msg|
      # incoming message observer expects messages to have the @-reply username removed
      text = msg.text.gsub("@#{TwitterAuth.config['gamebot_user']} ", '')
      count += 1 if self.create_from_twitter(msg.id, msg.user.screen_name, text)
    end

    # fetch direct messages
    # TODO: should discriminate between these if we need villager votes to be public
    self.twitter.direct_messages(conditions).each do |msg|
      count += 1 if self.create_from_twitter(msg.id, msg.sender.screen_name, msg.text)
    end

    logger.info("[MSG] Processed #{count} replies and direct messages")
    count
  end

  # create a new message from Twitter message data
  def self.create_from_twitter(id, sender, text)
    if (user = User.find_by_login(sender)) && user.active_player
      model = self.new(:from_user => user, :game => user.active_player.game, :text => text, :status_id => id)
      if model.save
        true
      else
        logger.error("[MSG] Unable to save message with status=#{id}: #{model.errors.full_messages.to_sentence}")
        false
      end
    else
      logger.error("[MSG] User #{sender} is not playing in any game!")
      false
    end
  end

  # send a quick reply to this message
  def reply(text)
    game.outgoing_messages.create(:to_user => from_user, :text => text)
  end
end
