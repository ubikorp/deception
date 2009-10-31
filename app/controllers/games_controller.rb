class GamesController < ApplicationController
  before_filter :login_required, :only => [:new, :create, :destroy, :start, :vote]
  before_filter :find_game, :only => [:show, :destroy, :start, :vote]
  before_filter :ownership_required, :only => [:destroy, :start]
  before_filter :membership_required, :only => [:vote]
  before_filter :playable_required, :only => [:vote]

  default_illustration :villager

  # list of currently ongoing games
  def index
    @title = "Active (Ongoing) Games"
    @games = Game.current.paginate(:page => params[:page] || 1, :per_page => 12, :order => 'created_at DESC')
  end

  # list of games that are seeking players
  def pending
    @title = "Games Looking for Players"
    @games = Game.pending.paginate(:conditions => { :invite_only => false }, :page => params[:page] || 1, :per_page => 12, :order => 'created_at DESC')
    render(:action => 'index')
  end

  # list of games that have been completed
  def finished
    @title = "Werewolf Game Archive"
    @games = Game.finished.paginate(:page => params[:page] || 1, :per_page => 12, :order => 'created_at DESC')
    render(:action => 'index')
  end

  # new game form
  def new
    if current_user.active_player
      flash[:error] = "Sorry, you cannot participate in more than one game at a time"
      redirect_to(game_path(current_user.active_player.game))
    else
      @game = Game.new
      @title = "New Game Village"
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
      @title = "New Game Village"
      flash[:error] = "Please check the form for errors"
      render(:action => 'new')
    end
  end

  # show details for a specific game
  def show
    if logged_in?
      @invitation = @game.invitations.for_user(current_user)
    else
      store_location # for direct-login stuffs
      @invitation = nil
    end

    @title = "The Incident at #{@game.name}"

    respond_to do |format|
      format.html do
        if @game.ready?
          render(:action => 'working')
        elsif @game.finished?
          @illustration = Illustration.find_by_title(@game.winner[0].type.to_s.downcase)
          render(:action => 'show')
        elsif @game.playable?
          @illustration = Illustration.find_by_title(@game.night? ? 'werewolf' : 'villager')
          render(:action => 'working') if @game.current_period.time_remaining < 1
        else
          render(:action => 'show')
        end
      end

      # TODO: clean this up, a little hacky the way we're using response codes
      format.js do
        if @game.ready? # not ready; retry later
          render(:nothing => true, :status => 408)
        elsif @game.playable? && @game.current_period.time_remaining <= 0
          render(:nothing => true, :status => 408)
        else # reset content
          render(:nothing => true, :status => 205)
        end
      end
    end
  end

  # real-time dashboard
  def dashboard
    if logged_in?
      @invitation = @game.invitations.for_user(current_user)
    else
      store_location # for direct-login stuffs
      @invitaiton = nil
    end

    @title = "The Incident at #{@game.name}"
    if @game.finished?
      @illustration = Illustration.find_by_title(@game.winner[0].type.to_s.downcase)
    elsif @game.playable?
      @illustration = Illustration.find_by_title(@game.night? ? 'werewolf' : 'villager')
    end
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
      if vote = current_user.vote(@user)
        flash[:notice] = if vote.period.phase == :night
          "Aye, he looks like a tasty one."
        else
          "Yeah, that one sure looks suspicious to me."
        end
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
    @game = Game.find_by_short_code(params[:id])
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
