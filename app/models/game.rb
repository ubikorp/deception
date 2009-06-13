# == Schema Information
#
# Table name: games
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Game < ActiveRecord::Base
  has_many :players
  has_many :users, :through => :players

  has_many :events

  validates_presence_of :name
end
