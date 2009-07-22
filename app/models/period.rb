# == Schema Information
#
# Table name: periods
#
#  id         :integer         not null, primary key
#  game_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Period < ActiveRecord::Base
  PHASES = [:night, :day]
  belongs_to :game
  has_many   :events, :dependent => :destroy

  validates_presence_of :game_id

  def phase
    index = game.periods.index(self)
    PHASES[(index || 0) % 2]
  end

  def day
    (game.periods.index(self) / 2) + 1
  end
end
