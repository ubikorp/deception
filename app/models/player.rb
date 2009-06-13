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
end

#class Villager < Player; end
#class Werewolf < Player; end
