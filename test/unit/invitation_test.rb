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

require 'test_helper'

class InvitationTest < ActiveSupport::TestCase
  def setup
    Factory(:invitation)
  end

  should_belong_to :game

  should_validate_presence_of   :game_id, :twitter_login
  should_validate_uniqueness_of :twitter_login, :scoped_to => :game_id
end
