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

    self.twitter.replies(conditions).each do |msg|
      if (user = User.find_by_login(msg.user.screen_name)) && user.active_player
        model = self.new(:from_user => user, :game => user.active_player.game, :text => msg.text, :status_id => msg.id)
        if model.save
          count += 1
        else
          logger.error("Unable to save message with status=#{msg.id}: #{model.errors.full_messages.to_sentence}")
        end
      else
        logger.error("User #{msg.user.screen_name} is not playing in any game!")
      end

      logger.info("Processed #{count} messages")
      count
    end
  end

  # send a quick reply to this message
  def reply(text)
    game.outgoing_messages.create(:to_user => from_user, :text => text)
  end
end
