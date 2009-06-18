# == Schema Information
#
# Table name: events
#
#  id               :integer         not null, primary key
#  type             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  source_player_id :integer
#  target_player_id :integer
#  period_id        :integer
#

# Base class for all game actions
class Event < ActiveRecord::Base
  named_scope :quits, :conditions => { :type => 'QuitEvent' }
  named_scope :kills, :conditions => { :type => 'KillEvent' }
  named_scope :votes, :conditions => { :type => 'VoteEvent' }

  belongs_to :period
  belongs_to :source_player, :class_name => 'Player', :foreign_key => :source_player_id
  belongs_to :target_player, :class_name => 'Player', :foreign_key => :target_player_id

  validates_presence_of :period_id

  def validate
    # custom validator to check that source player is in this game and is alive
    if source_player
      errors.add(:source_player_id, "is not playing in this game") unless game.players.alive.include?(source_player)
    end
  end

  def game
    period.game
  end
end
