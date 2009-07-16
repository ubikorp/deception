module GamesHelper
  def user_can_join(game)
    return false unless logged_in? 

    if game.invite_only
      game.invitations.includes_user(current_user)
    else
      true
    end
  end
end
