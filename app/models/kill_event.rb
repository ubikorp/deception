# == Schema Information
#
# Table name: events
#
#  id               :integer         not null, primary key
#  game_id          :integer
#  type             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  source_player_id :integer
#  target_player_id :integer
#

class KillEvent < Event
end
