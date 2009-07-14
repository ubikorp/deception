class GamesController < ApplicationController
  before_filter :login_required, :only => [:new, :create]

  # list of currently ongoing games
  def index
    @games = Game.current
  end

  # list of games that are seeking players
  def available
    @games = Game.available
  end

  # list of games that have been completed
  def finished
    @games = Game.finished
  end

  # new game form
  def new
    if current_user.active_player
      flash[:error] = "Sorry, you cannot participate in more than one game at a time"
      redirect_to(game_path(current_user.active_player.game))
    else
      @game = Game.new
    end
  end

  # create new game
  def create
    @game = Game.new(params[:game].merge(:owner => current_user))
    if @game.save
      current_user.join(@game)
      flash[:notice] = "Your game has been created"
      redirect_to(game_path(@game))
    else
      flash[:error] = "Please check the form for errors"
      render(:action => 'new')
    end
  end

  # show details for a specific game
  def show
    @game = Game.find(params[:id])
  end
end
