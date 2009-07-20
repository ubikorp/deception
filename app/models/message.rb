# == Schema Information
#
# Table name: messages
#
#  id           :integer         not null, primary key
#  game_id      :integer
#  target       :string(255)
#  text         :string(255)
#  delivered_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#

class Message < ActiveRecord::Base
  named_scope :delivered,   :conditions => "delivered_at IS NOT NULL"
  named_scope :undelivered, :conditions => "delivered_at IS NULL"

  belongs_to  :game

  validates_presence_of :text, :game_id

  def self.twitter
    @@twitter ||= Message.initialize_twitter
  end

  # initialize the Twitter message handling facility
  def self.initialize_twitter
    # TODO: use oauth here instead of httpauth

    # oauth = Twitter::OAuth.new(config['oauth_consumer_key'], config['oauth_consumer_secret'])
    # oauth.authorize_from_access(config['oauth_access_token'], config['oauth_access_secret'])
    # @@twitter = Twitter::Base.new(oauth)

    httpauth  = Twitter::HTTPAuth.new(TwitterAuth.config['gamebot_user'], TwitterAuth.config['gamebot_password'])
    @@twitter = Twitter::Base.new(httpauth)
  end

  # send undelivered messages
  # messages with no target are broadcast to all living members of the specified game
  def self.send_messages
    self.undelivered.each do |msg|
      if msg.target.nil?
        msg.game.players.alive.each do |recipient|
          # broadcast direct message to all active players
          Message.twitter.direct_message_create(recipient.user.login, msg.text)
        end
      else
        # send direct message to this user only
        Message.twitter.direct_message_create(msg.target, msg.text)
      end
      msg.delivered!
    end
  end

  # mark this message as delivered
  def delivered!
    self.update_attribute(:delivered_at, Time.now)
  end
end
