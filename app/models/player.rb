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

  def werewolf?
    type == 'Werewolf'
  end

  def villager?
    type == 'Villager'
  end
end
