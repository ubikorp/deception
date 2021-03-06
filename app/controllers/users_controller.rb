class UsersController < ApplicationController
  before_filter :login_required, :except => [:new]

  default_illustration :villager

  # new users are created through signin with Twitter
  def new
    redirect_to(login_path)
  end

  # show user profile (always the current user for now)
  # TODO: publicly visible user profiles?
  def show
    @user = current_user
    @title = "Account and Notification Settings"
  end

  # update user profile and notification preferences
  def update
    @user = current_user
    if @user.update_attributes(params[:user])
      flash[:notice] = "Updated your account settings!"
      redirect_to(account_path)
    else
      @title = "Account and Notification Settings"
      flash[:error] = "Error updating your account settings."
      render(:action => 'show')
    end
  end

  # a user can have us auto-add a gamebot follow for them
  def follow
    begin
      if !current_user.following?
        current_user.follow_game
        flash[:notice] = "You should now be following @#{TwitterAuth.config['gamebot_user']} on Twitter."
      else
        flash[:notice] = "You are already following @#{TwitterAuth.config['gamebot_user']} on Twitter."
      end
    rescue TwitterAuth::Dispatcher::Error
      flash[:error] = "Unable to communicate your request to Twitter. Try again later."
    end

    return_url = params[:game_id] ? game_path(params[:game_id]) : '/'
    redirect_to(return_url)
  end

  # get a list of users who follow this twitter account
  # returns json for ajax calls (invitations/new)
  def followers
    begin
      @followers = current_user.twitter.get("/statuses/followers?page=#{params[:page] || 1}")
    rescue TwitterAuth::Dispatcher::Error
      @followers = []
    end

    status = @followers.empty? ? 404 : 200

    respond_to do |format|
      format.html { render(:action => 'followers', :status => status) }
      format.json { render(:json => @followers.to_json, :status => status) }
    end
  end
end
