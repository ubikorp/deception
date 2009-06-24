# == Schema Information
#
# Table name: games
#
#  id            :integer         not null, primary key
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  state         :string(255)
#  invite_only   :boolean
#  min_players   :integer
#  period_length :integer
#  short_code    :string(255)
#  owner_id      :integer
#  max_players   :integer
#

require 'array_ext'
require 'short_round'

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
      transition :setup => :playable, :if => :startable?
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

  validates_presence_of     :name, :owner_id, :period_length, :min_players, :max_players
  validates_numericality_of :period_length, :min_players, :max_players
  validates_inclusion_of    :min_players,   :within => APP_CONFIG[:min_players]..APP_CONFIG[:max_players], :message => "is outside the acceptable range"
  validates_inclusion_of    :max_players,   :within => APP_CONFIG[:min_players]..APP_CONFIG[:max_players], :message => "is outside the acceptable range"
  validates_inclusion_of    :period_length, :within => APP_CONFIG[:min_period_length]..APP_CONFIG[:max_period_length], :message => "is outside the acceptable range"

  before_validation_on_create :set_defaults
  after_create                :generate_short_code

  # Check status of playable games and update them, moving to the next period if the time is right
  def self.update_periods
    Game.with_state(:playable).each do |game|
      if game.next_period_starts_at <= Time.now
        logger.info "Next period for Game [#{game.id}]"
        game.continue
      end
    end
  end

  [:invite_only, :min_players, :max_players, :period_length].each do |setter|
    define_method("#{setter.to_s}=") do |value|
      if setup?
        write_attribute(setter, value)
      else
        raise GameException::GameInProgress, "Cannot set game options after setup phase"
      end
    end
  end

  def to_param
    short_code
  end

  def current_period
    periods.last
  end

  def next_period_starts_at
    if playable?
      periods.last.created_at + period_length
    else
      nil
    end
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

  # game is startable if minimum player requirement is met, etc
  def startable?
    players.length >= APP_CONFIG[:min_players]
  end

  def set_defaults
    self.invite_only   = APP_CONFIG[:invite_only] if invite_only.nil?
    self.period_length = APP_CONFIG[:default_period_length] if period_length.nil?
    self.min_players   = APP_CONFIG[:min_players] if min_players.nil?
    self.max_players   = APP_CONFIG[:max_players] if max_players.nil?
  end

  def generate_short_code
    self.update_attribute(:short_code, ShortRound.generate(self.id))
  end
end
