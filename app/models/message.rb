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
#

class Message < ActiveRecord::Base
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
end
