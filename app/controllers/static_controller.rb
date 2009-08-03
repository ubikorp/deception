class StaticController < ApplicationController
  default_illustration :werewolf

  def index
    @users = User.all(:order => "created_at DESC", :limit => 10)
  end

  def help
    @title = "Directions and Game Play Information"
    @illustration = Illustration.find_by_title('seer')
  end
end
