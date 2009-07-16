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
  named_scope :pending,   :conditions => { :state => 'setup', :invite_only => false }
  named_scope :current,   :conditions => { :state => 'playable' }
  named_scope :finished,  :conditions => { :state => 'finished' }

  has_many :players
  has_many :users, :through => :players

  has_many :invitations do
    def includes_user(user)
      self.map { |i| i.twitter_login }.include?(user.login)
    end
  end

  has_many :periods, :order => :created_at
  has_many :events, :through => :periods

  belongs_to :owner, :class_name => 'User', :foreign_key => :owner_id

  state_machine :initial => :setup do
    state :ready, :playable, :finished

    # used by player to manually start (queue for sync start)
    event :ready do
      transition :setup => :ready, :if => :startable?
    end

    # start the game
    event :start do
      transition :ready => :playable, :if => :startable?
      transition :setup => :playable, :if => :startable?
    end

    # end the game
    event :finish do
      transition :playable => :finished
    end

    # start next phase / round of play
    event :continue do
      transition :waiting  => :playable
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
  after_create                :generate_short_code #, :add_owner_as_player

  # Check status of playable games and update them, moving to the next period if the time is right
  def self.update_periods
    Game.with_state(:playable).each do |game|
      if game.next_period_starts_at <= Time.now
        logger.info "Next period for Game [#{game.id}]"
        game.continue
      end
    end

    # user requested start
    Game.with_state(:ready).each do |game|
      logger.info "Starting Game [#{game.id}]"
      game.start
    end

    # game auto-start
    Game.with_state(:setup).each do |game|
      if game.players.length >= game.max_players
        logger.info "Auto-Starting Game [#{game.id}]"
        game.start
      end
    end
  end

  [:invite_only, :min_players, :max_players, :period_length].each do |setter|
    define_method("#{setter.to_s}=") do |value|
      if new_record? || setup? 
        write_attribute(setter, value)
      else
        raise GameException::GameInProgress, "Cannot set game options after setup phase"
      end
    end
  end

  def validate
    # period length should always be a multiple of min_period_length
    if period_length
      errors.add(:period_length, "must be a multiple of #{APP_CONFIG[:min_period_length]}") unless (period_length % APP_CONFIG[:min_period_length] == 0)
    end

    # a user can only participate in one game at a time
    # if owner
    #   errors.add(:owner, "is already an active member of another game") if owner.active_player
    # end
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
    else # day
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
    if players.length < APP_CONFIG[:min_players]
      errors.add_to_base("This game must have at least #{APP_CONFIG[:min_players]} players")
      false
    else
      true
    end
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

  def add_owner_as_player
    self.owner.join(self)
  end
end
