# == Schema Information
#
# Table name: invitations
#
#  id            :integer         not null, primary key
#  game_id       :integer
#  twitter_login :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#

class Invitation < ActiveRecord::Base
  belongs_to :game

  validates_presence_of   :game_id, :twitter_login
  validates_uniqueness_of :twitter_login, :scope => :game_id
end
