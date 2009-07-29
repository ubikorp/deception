class GamesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :destroy, :start, :vote]
  before_filter :find_game, :only => [:show, :destroy, :start, :vote]
  before_filter :ownership_required, :only => [:destroy, :start]
  before_filter :membership_required, :only => [:vote]
  before_filter :playable_required, :only => [:vote]

  # list of currently ongoing games
  def index
    @title = "Active (Ongoing) Games"
    @games = Game.current
  end

  # list of games that are seeking players
  def pending
    @title = "Games Looking for Players"
    @games = Game.pending(:conditions => { :invite_only => false })
  end

  # list of games that have been completed
  def finished
    @title = "Werewolf Game Archive"
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
    # TODO: add custom art
    # @illustration = @game.day? ? Illustration.find_by_name('villagers') : Illustration.find_by_name('werewolf')
    store_location if !logged_in? # for direct-login stuffs
  end

  # destroy a game during the setup phase
  def destroy
    if @game.setup?
      @game.destroy
      flash[:notice] = "The game has been aborted"
      redirect_back_or_default(games_path)
    else
      flash[:error] = "You cannot delete a game after it has started"
      redirect_back_or_default(games_path)
    end
  end

  # start a game, if game start criteria is satisfied
  def start
    if @game.setup? && @game.startable?
      flash[:notice] = "The game will begin shortly!"
      @game.ready # manual start
    else
      flash[:error] = "Unable to start this game"
    end

    redirect_to(game_path(@game))
  end

  # record a vote in this game
  def vote
    if @user = User.find((params[:vote] || {})[:user_id])
      if current_user.vote(@user)
        flash[:notice] = @game.night? ? "Aye, he looks like a tasty one." : "Yeah, that one sure looks suspicious to me."
      else
        flash[:error] = "Unable to record your vote. Please try again."
      end
    else
      flash[:error] = "Votes for this player are not allowed."
    end
    redirect_to(game_path(@game))
  end

  private

  def find_game
    @game = Game.find(params[:id])
  end

  def ownership_required
    (current_user == @game.owner) || access_denied
  end

  def membership_required
    @game.players.alive.include?(current_user.active_player) || access_denied
  end

  def playable_required
    @game.playable? || access_denied
  end
end
