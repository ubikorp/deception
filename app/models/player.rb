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
#

class Player < ActiveRecord::Base
  belongs_to :user
  belongs_to :game

  validates_presence_of :user_id, :game_id
  validates_uniqueness_of :user_id, :scope => :game_id

  # indicates whether this user has been killed
  def dead?
    !game.events.quits.select { |e| e.source_player_id == self.id }.empty? || 
      !game.events.kills.select { |e| e.target_player_id == self.id }.empty?
  end
end
