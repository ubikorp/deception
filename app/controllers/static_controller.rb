class StaticController < ApplicationController
  def index
    @users = User.all(:order => "created_at DESC", :limit => 10)
  end
end
