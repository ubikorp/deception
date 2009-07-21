# == Schema Information
#
# Table name: messages
#
#  id           :integer         not null, primary key
#  game_id      :integer
#  text         :string(255)
#  delivered_at :datetime
#  created_at   :datetime
#  updated_at   :datetime
#  type         :string(255)
#  from_user_id :integer
#  to_user_id   :integer
#

class IncomingMessage < Message
  belongs_to :from_user, :class_name => "User"

  validates_presence_of :from_user_id

  # TODO: after_create :record_event

  # poll twitter for new game messages
  def self.receive_messages
    # TODO
  end
end
