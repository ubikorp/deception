# == Schema Information
#
# Table name: invitations
#
#  id            :integer         not null, primary key
#  game_id       :integer
#  twitter_login :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  invited_by_id :integer
#

class Invitation < ActiveRecord::Base
  belongs_to :game
  belongs_to :invited_by, :class_name => 'User'

  validates_presence_of   :game_id, :twitter_login, :invited_by_id
  validates_uniqueness_of :twitter_login, :scope => :game_id

  before_validation :check_referer

  private

  def check_referer
    if game
      self.invited_by = game.owner if invited_by.nil?
    end
  end
end
