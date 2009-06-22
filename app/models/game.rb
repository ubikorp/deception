# == Schema Information
#
# Table name: games
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  state            :string(255)
#  invite_only      :boolean
#  player_threshold :integer
#  period_length    :integer
#  short_code       :string(255)
#  owner_id         :integer
#

require 'array_ext'

class Game < ActiveRecord::Base
  has_many :players
  has_many :invitations
  has_many :users, :through => :players

  has_many :periods, :order => :created_at
  has_many :events, :through => :periods

  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id

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

  validates_presence_of :name, :owner_id
  before_create         :set_defaults

  [:invite_only, :player_threshold, :period_length].each do |setter|
    define_method("#{setter.to_s}=") do |value|
      if setup?
        write_attribute(setter, value)
      else
        raise GameException::GameInProgress, "Cannot set game options after setup phase"
      end
    end
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

  def set_defaults
    self.invite_only      ||= APP_CONFIG[:invite_only]
    self.player_threshold ||= APP_CONFIG[:player_threshold]
    self.period_length    ||= APP_CONFIG[:period_length]
  end
end
