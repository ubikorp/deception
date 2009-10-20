class DeceptionHandler < BirdGrinder::CommandHandler

  BirdGrinder::Loader.before_run do
    logger.info "Checking for deception path"
    if BirdGrinder::Settings[:deception_path]
      logger.info "Loading deception from #{BirdGrinder::Settings[:deception_path]}"
      ENV['RAILS_ENV'] ||= 'production'
      require File.join(BirdGrinder::Settings[:deception_path], "config", "environment")
    end
  end

  exposes :vote, :quit, :help, :kill
  
  def vote(text)
    check_game_status!
    names = extract_names(text)

    if names.length != 1
      # reply 
      return
    end

    target_user = user_named(names.first)
    if target_user && current_deception_user.vote(target_user)
      logger.info("Created a VoteEvent from msg (@#{current_deception_user.login}): #{text}")
      reply DeceptionGame::Messages.build(:bot_valid_vote_reply), :type => :dm
    else
      logger.error("Unable to create VoteEvent from msg (@#{current_deception_user.login}): #{text}")
      reply DeceptionGame::Messages.build(:bot_invalid_vote_reply), :type => :dm
    end
  end

  alias kill vote
  
  def quit(text)
    check_game_status!

    if current_deception_user.quit
      logger.info("Created a QuitEvent from msg (@#{current_deception_user.login}): #{text}")
      reply DeceptionGame::Messages.build(:bot_quit_reply), :type => :dm
    else
      logger.info("Unable to create QuitEvent from msg (@#{current_deception_user.login}): #{text}")
      reply "Oh Noes! I couldn't quit", :type => :dm
    end
  end
  
  def help(text)
    reply DeceptionGame::Messages.build(:bot_help_reply), :type => :dm
  end
  
  def setup_env
  end
  
  def reset_env
  end
  
  protected
  
  def user_named(name)
    User.find_by_login(name)
  end
  
  def current_deception_user
    @current_deception_user ||= user_named(@user)
  end
  
  def check_game_status! 
    if current_deception_user.blank?
      reply "The Game. You lost it.", :type => :dm
    elsif current_deception_user.active_player.blank?
      reply "You're not currently in a game, champ. Why not join one by visiting http://werewolfgame.net", :type => :dm
    else
      return
    end
    halt_handlers!
  end
  
  def extract_names(text)
    text.scan /@\w+/
  end
  
  def reset_details
    super
    @current_deception_user = nil
  end
  
end
