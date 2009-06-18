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

require 'test_helper'

class VillagerTest < ActiveSupport::TestCase
  context 'villager' do
    # ...
  end
end
