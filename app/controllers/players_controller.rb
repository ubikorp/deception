class PlayersController < ApplicationController
  before_filter :login_required # all
  before_filter :find_game

  # join a game (join)
  def create
    if current_user.join(@game)
      flash[:notice] = "Thanks for joining up! We'll send you a direct message when the game starts."
    else
      flash[:error] = "Sorry you are unable to join this game."
    end
    redirect_to(game_path(@game))
  end

  # remove yourself from a game (quit)
  def destroy
    if @game.players.include?(current_user.active_player)
      QuitEvent.new
    end
  end

  private

  def find_game
    @game = Game.find(params[:game_id])
  end
end
