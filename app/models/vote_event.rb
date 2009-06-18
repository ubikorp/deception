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

class VoteEvent < Event
  validates_presence_of   :source_player_id, :target_player_id
  validates_uniqueness_of :source_player_id, :scope => :period_id
end
