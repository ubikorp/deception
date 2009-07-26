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
  # validates_uniqueness_of :source_player_id, :scope => :period_id

  before_save :delete_last_vote

  private

  # certain roles can only vote at certain times
  # users cannot vote during night (werewolf) phases
  def validate
    if period && source_player
      errors.add_to_base("Villagers cannot vote during a night phase") if (period.phase == :night) && source_player.villager?
    end

    super
  end

  # ensure that a player can only have one vote during a period
  # iow, remove old vote (in same period) before creating new one
  def delete_last_vote
    if vote = VoteEvent.find_similar(self)
      vote.destroy
    end
  end

  def self.find_similar(vote)
    VoteEvent.find(:first, :conditions => { :source_player_id => vote.source_player_id, :period_id => vote.period_id })
  end
end
