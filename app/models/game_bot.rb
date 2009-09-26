class GameBot
  def self.messages
    @client ||= initialize_messages
  end

  def self.twitter
    @twitter ||= initialize_twitter
  end

  # initialize the Twitter message handling facility
  # this is a private method, used to set up the twitter class method
  def self.initialize_twitter
    # TODO: use oauth here instead of httpauth

    # oauth = Twitter::OAuth.new(config['oauth_consumer_key'], config['oauth_consumer_secret'])
    # oauth.authorize_from_access(config['oauth_access_token'], config['oauth_access_secret'])
    # @twitter = Twitter::Base.new(oauth)

    httpauth  = Twitter::HTTPAuth.new(TwitterAuth.config['gamebot_user'], TwitterAuth.config['gamebot_password'])
    @twitter = Twitter::Base.new(httpauth)
  end

  def self.initialize_messages
    @client = BirdGrinderClient.new
  end

  private_class_method :initialize_twitter
  private_class_method :initialize_messages
end
