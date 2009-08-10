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

class Werewolf < Player
  def peer
    game.werewolves.detect { |w| w.user_id != self.user_id }
  end
end
