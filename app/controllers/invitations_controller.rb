class InvitationsController < ApplicationController
  before_filter :find_game # all
  before_filter :user_can_invite # all

  default_illustration :seer

  # show invitation options
  def new
    @title = "Invite Your Friends (and Enemies)"
    begin
      @followers = current_user.twitter.get('/statuses/followers')
    rescue TwitterAuth::Dispatcher::Error
      flash[:error] = "Sorry, could we could not load your follower list"
      @followers = []
    end
  end

  # process invitations
  # params[:invitations] should contain a comma-separated list of twitter screen names to invite
  def create
    successes = []
    (params[:invitations].split(',') || []).each do |name|
      name.strip!
      invitation = @game.invitations.build(:twitter_login => name, :invited_by => current_user)
      successes << name if invitation.save
      # TODO: send actual invitations as DMs from the user??
      # TODO: verify that the listed people are actually followers of the user?
    end
    flash[:notice] = "Invitations have been sent to the #{successes.length} people you selected"
    redirect_to(game_path(@game))
  end

  private

  def user_can_invite
    (login_required && (!@game.invite_only? || (@game.owner == current_user))) || access_denied
  end

  def find_game
    @game = Game.find_by_short_code(params[:game_id])
  end
end
