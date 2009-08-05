# == Schema Information
#
# Table name: players
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  game_id    :integer
#  type       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  dead       :boolean
#

class Player < ActiveRecord::Base
  named_scope :alive,      :conditions => { :dead => false }
  named_scope :villagers,  :conditions => { :type => 'Villager' }
  named_scope :werewolves, :conditions => { :type => 'Werewolf' }

  belongs_to :user
  belongs_to :game

  validates_presence_of :user_id, :game_id
  validates_uniqueness_of :user_id, :scope => :game_id

  def validate
    if game
      errors.add(:game_id, "is already in progress") if !game.state?(:setup)
      errors.add(:game_id, "is full") if game.full?
    end
  end

  def werewolf?
    type == 'Werewolf'
  end

  def villager?
    type == 'Villager'
  end

  # used to assign a role to the player when game is about to start
  def assign_role(role = :villager)
    klass = role.to_s.classify.constantize
    if klass.new.is_a?(Player)
      self.update_attribute(:type, role.to_s.classify)
      klass.find(self.id)
    else
      false
    end
  end

  # used to discover what player, if any, this player voted for in a given period
  def voted_in_period(period)
    if vote = period.events.votes.detect { |v| v.source_player == self }
      vote.target_player
    else
      false
    end
  end
end
