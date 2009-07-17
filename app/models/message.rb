class Message < ActiveRecord::Base
  belongs_to :game

  validates_presence_of :target, :text, :game_id

  def delivered!
    self.update_attribute(:delivered_at, Time.now)
  end
end
