# == Schema Information
#
# Table name: games
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  state      :string(255)
#

class Game < ActiveRecord::Base
  has_many :players
  has_many :users, :through => :players

  has_many :events

  validates_presence_of :name

  state_machine :initial => :setup do
    state :day, :night, :completed

    event :start do
      transition :setup => :day
    end

    event :end do
      transition all => :completed
    end

    event :continue do
      transition :day   => :night
      transition :night => :day
    end

    after_transition [:day, :night] => [:day, :night], :do => :reduce
  end

  def reduce
    # kill people
  end
end
