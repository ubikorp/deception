class InvitationObserver < ActiveRecord::Observer
  include ActionController::UrlWriter

  def after_create(invitation)
    # TODO: host is temporary
    msg = DeceptionGame::Messages.build(:invitation, game_url(invitation.game, :host => 'werewolfgame.net'))
    invitation.invited_by.twitter.post('/direct_messages/new', 'text' => msg, 'user' => invitation.twitter_login)
  end
end
