class PlayersController < ApplicationController
  before_filter :login_required # all
  before_filter :find_game
  before_filter :membership_required, :except => [:create]

  # join a game (join)
  def create
    if current_user.join(@game)
      flash[:notice] = "Thanks for joining up! If you follow us on Twitter, we'll send you a direct message when the game starts."
      session[:follow_prompt] = true
    else
      flash[:error] = "Sorry you are unable to join this game."
    end
    redirect_to(game_path(@game))
  end

  # remove yourself from a game (quit)
  def destroy
    current_user.quit
    flash[:notice] = "Your player has committed suicide and left this game. So tragic!"
    redirect_to game_path(@game)
  end

  private

  def find_game
    @game = Game.find_by_short_code(params[:game_id])
  end

  def membership_required
    @game.players.include?(current_user.active_player) || access_denied
  end
end
