class GamesController < ApplicationController
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
end
