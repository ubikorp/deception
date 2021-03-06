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
#  deleted_at    :datetime
#

require 'array_ext'
require 'short_round'

class Game < ActiveRecord::Base
  named_scope :pending,   :conditions => { :state => 'setup', :invite_only => false }, :order => 'created_at DESC'
  named_scope :current,   :conditions => { :state => 'playable' },                     :order => 'created_at DESC'
  named_scope :finished,  :conditions => { :state => 'finished' },                     :order => 'created_at DESC'
  is_paranoid

  has_many :players, :dependent => :destroy
  has_many :users, :through => :players

  has_many :invitations do
    def for_user(user)
      self.detect { |i| i.twitter_login == user.login }
    end
  end

  has_many :periods, :order => :created_at, :dependent => :destroy
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
      transition :ready    => :playable
      transition :playable => :playable
    end

    before_transition :setup    => [:ready, :playable], :do => :assign_roles
    before_transition :playable => :playable,           :do => :end_turn
    after_transition  all       => :playable,           :do => :next_phase
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
      if game.current_period.finished?
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
    # NOTE: moved to observer on player model
    # Game.with_state(:setup).each do |game|
    #   if game.players.length >= game.max_players
    #     logger.info "Auto-Starting Game [#{game.id}]"
    #     game.start
    #   end
    # end
  end

  [:invite_only, :min_players, :max_players, :period_length].each do |setter|
    define_method("#{setter.to_s}=") do |value|
      if new_record? || setup? 
        write_attribute(setter, value)
      else
        raise DeceptionGame::Exception::GameInProgress, "Cannot set game options after setup phase"
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

  def full?
    players(true).length >= max_players
  end

  def current_period
    periods(true).last
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
    # TODO: adjust this for games with > 2 werewolves
    bwerewolves = werewolves.length > 0
    bvillagers = villagers.length > werewolves.length
    if bvillagers && bwerewolves
      false
    elsif bvillagers
      villagers
    elsif bwerewolves
      werewolves
    else
      false
    end
  end

  def winner_type
    if finished? && winner
      winner.first.type.to_s.pluralize
    else
      nil
    end
  end
  
  # game is startable if minimum player requirement is met, etc
  def startable?
    return false unless setup? || ready?

    if players(true).length < APP_CONFIG[:min_players]
      errors.add_to_base("This game must have at least #{APP_CONFIG[:min_players]} players")
      false
    else
      true
    end
  end

  private

  # assign roles (like villager, werewolf, etc) to players in this game
  # called as a before-transiton action when leaving the setup state
  #
  # note that if we've already 'hinted' the player type for a user,
  # this needs to respect that.
  def assign_roles
    # TODO: make this less 'dumb'; see multi-werewolf game statistics
    wolf_candidates = []
    players_without_roles = players.select { |p| p.type.nil? }
    # wolf_candidates = (werewolves.length > 0) ? [] : [rand(players_without_roles.length)]
    number_to_assign = [ideal_number_of_werewolves - werewolves.length, players_without_roles.length].min

    until wolf_candidates.length == number_to_assign do
      candidate = rand(players_without_roles.length)
      wolf_candidates << candidate unless wolf_candidates.include?(candidate)
    end

    players_without_roles.each_with_index do |player, i|
      role = wolf_candidates.include?(i) ? :werewolf : :villager
      player.assign_role(role)
    end
  end

  # tally villager or werewolf votes and remove the victim(s) from play
  # called as a before-transition filter
  def end_turn
    # TODO: simplify this... kinda brittle
    if night?
      candidates = current_events.votes.select { |e| e.source_player.werewolf? }.map { |e| e.target_player }
      candidates = werewolves.length > 1 ? candidates.modes : candidates
    else # day
      candidates = current_events.votes.map { |e| e.target_player }.modes || []
    end

    if victim = (candidates || []).first
      logger.info "End of turn for Game [#{id}] : Victim is #{victim.user.login}"
      KillEvent.create(:period => current_period, :target_player => victim)
    else
      logger.info "End of turn for Game [#{id}] : Nobody was killed this period"
    end
  end

  # check to see if a winner has been determined
  # if not, move on to the next phase
  # called as an after-transition filter
  def next_phase
    if winner
      logger.info "Ending Game [#{id}]"
      finish
    else
      periods.create
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

  # determines the number of werewolves that should be playing in a game
  def ideal_number_of_werewolves
    if self.players.length < 9
      1
    elsif self.players.length < APP_CONFIG[:max_players]
      2
    end
  end
end
