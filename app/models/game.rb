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
    state :playable, :completed

    event :start do
      transition :setup => :playable
    end

    event :end do
      transition all => :completed
    end

    event :continue do
      transition :playable => :playable
    end

    after_transition :setup => :playable, :do => :create_first_period
    before_transition :playable => :playable, :do => :next_phase
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
  
  private

  def create_first_period
    periods.create
  end

  # tally villager or werewolf votes and remove the victim(s) from play
  # then move on to the next period
  def next_phase
    victims = if night?
      current_events.votes.select { |e| e.source_player.werewolf? }.map { |e| e.target_player }
    else
      current_events.votes.map { |e| e.target_player }.modes || []
    end

    victims.each { |victim| KillEvent.create(:period => current_period, :target_player => victim) }
    periods.create
  end
end
