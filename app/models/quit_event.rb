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

class QuitEvent < Event
  validates_presence_of :source_player_id

  after_create :kill_player

  private

  def kill_player
    source_player.update_attribute(:dead, true)
  end
end
