class InvitationsController < ApplicationController
  before_filter :find_game # all
  before_filter :user_can_invite # all

  # show invitation options
  def new
    # TODO: multiple pages of users; this is limited to 100 followers
    # TODO: remove users from the list that already have an invite to the game
    @followers = current_user.twitter.get('/statuses/followers')
    @title = "Invite Your Friends (and Enemies)"
  end

  # process invitations
  # params[:invitations] should contain a comma-separated list of twitter screen names to invite
  def create
    successes = []
    (params[:invitations].split(',') || []).each do |name|
      name.strip!
      invitation = @game.invitations.build(:twitter_login => name)
      successes << name if invitation.save
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
    @game = Game.find(params[:game_id])
  end
end
