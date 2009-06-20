# == Schema Information
#
# Table name: games
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  state      :string(255)
#

require 'array_ext'

class Game < ActiveRecord::Base
  has_many :players
  has_many :users, :through => :players

  has_many :periods, :order => :created_at
  has_many :events, :through => :periods

  validates_presence_of :name

  state_machine :initial => :setup do
    state :playable, :finished

    event :start do
      transition :setup => :playable
    end

    event :finish do
      transition :playable => :finished
    end

    event :continue do
      transition :playable => :playable
    end

    before_transition :playable => :playable, :do => :end_turn
    after_transition  all       => :playable, :do => :next_phase
  end

  def current_period
    periods.last
  end

  def current_events
    current_period.events
  end

  def werewolves
    players.alive.werewolves
  end

  def villagers
    players.alive.villagers
  end

  def day?
    (periods.length % 2) == 0
  end

  def night?
    (periods.length % 2) == 1
  end

  def winner
    villagers = players.villagers.alive.length > 0
    werewolves = players.werewolves.alive.length > 0
    if villagers && werewolves
      false
    elsif villagers
      players.villagers.alive
    elsif werewolves
      players.werewolves.alive
    else
      false
    end
  end
  
  private

  # tally villager or werewolf votes and remove the victim(s) from play
  # called as a before-transition filter
  def end_turn
    victims = if night?
      current_events.votes.select { |e| e.source_player.werewolf? }.map { |e| e.target_player }
    else
      current_events.votes.map { |e| e.target_player }.modes || []
    end

    victims.each { |victim| KillEvent.create(:period => current_period, :target_player => victim) }
  end

  # check to see if a winner has been determined
  # if not, move on to the next phase
  # called as an after-transition filter
  def next_phase
    if winner
      finish
    else
      periods.create
    end
  end
end
