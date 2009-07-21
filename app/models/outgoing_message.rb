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

class OutgoingMessage < Message
  named_scope :delivered,   :conditions => "delivered_at IS NOT NULL"
  named_scope :undelivered, :conditions => "delivered_at IS NULL"

  belongs_to :to_user, :class_name => "User"

  # send undelivered messages
  # messages with no explicit destination are broadcast to all living members of the specified game
  # returns total number of messages sent
  def self.send_messages
    logger.info("Sending outgoing status messages via Twitter...")
    broadcast_count = 0
    direct_count = 0

    self.undelivered.each do |msg|
      if msg.to_user.nil?
        msg.game.players.alive.each do |recipient|
          # broadcast direct message to all active players
          OutgoingMessage.twitter.direct_message_create(recipient.user.login, msg.text) && (broadcast_count += 1)
        end
      else
        # send direct message to this user only
        OutgoingMessage.twitter.direct_message_create(msg.to_user.login, msg.text) && (direct_count += 1)
      end
      msg.delivered!
    end

    logger.info("Message flush completed: Sent #{direct_count} direct messages and #{broadcast_count} broadcast (direct) messages")
    direct_count + broadcast_count
  end

  # mark this message as delivered
  def delivered!
    self.update_attribute(:delivered_at, Time.now)
  end
end
