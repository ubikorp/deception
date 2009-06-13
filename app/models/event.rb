# == Schema Information
#
# Table name: events
#
#  id             :integer         not null, primary key
#  game_id        :integer
#  source_user_id :integer
#  target_user_id :integer
#  created_at     :datetime
#  updated_at     :datetime
#

# Base class for all game actions
class Event < ActiveRecord::Base
  belongs_to :game
  belongs_to :source_player, :class_name => 'Player', :foreign_key => :source_player_id
  belongs_to :target_player, :class_name => 'Player', :foreign_key => :target_player_id

  validates_presence_of :game_id
end
