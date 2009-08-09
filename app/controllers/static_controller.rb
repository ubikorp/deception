class StaticController < ApplicationController
  default_illustration :werewolf

  def index
    if logged_in? && !current_user.active_player.nil?
      redirect_to(game_path(current_user.active_player.game))
    else
      @users = User.all(:order => "created_at DESC", :limit => 10)
    end
  end

  def help
    @title = "Directions and Game Play Information"
    @illustration = Illustration.find_by_title('seer')
  end
end
