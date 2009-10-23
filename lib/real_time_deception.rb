class RealTimeDeception

  @@games = {}

  def self.[](id)
    @@games[id] || self.new(id)
  end

  def self.reset!
    @@games = {}
  end

  def self.require_chainsaw
    require File.join(APP_CONFIG[:chainsaw_location], "lib", "chainsaw")
  end

  def initialize(game_id)
    self.class.require_chainsaw unless defined?(Chainsaw)
    @game_id = game_id
  end

  def event!(name, arguments = {})
    args = arguments.symbolize_keys
    args[:event] = name.to_s.gsub("_", "-")
    args[:game_id] = @game_id
    log.append(args)
  rescue SystemCallError
  end

  def log
    @log ||= Chainsaw::MessageLog["deception:games:#{game_id}"]
  end

end