class InvitationsController < ApplicationController
  before_filter :find_game # all
  before_filter :user_can_invite # all

  # show invitation options
  def new; end

  # process invitations
  def create
  end

  private

  def user_can_invite
    (login_required && (!@game.invite_only? || (@game.owner == current_user))) || access_denied
  end

  def find_game
    @game = Game.find(params[:game_id])
  end
end
