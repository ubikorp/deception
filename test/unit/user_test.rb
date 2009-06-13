# == Schema Information
#
# Table name: users
#
#  id                           :integer         not null, primary key
#  twitter_id                   :string(255)
#  login                        :string(255)
#  access_token                 :string(255)
#  access_secret                :string(255)
#  remember_token               :string(255)
#  remember_token_expires_at    :datetime
#  name                         :string(255)
#  location                     :string(255)
#  description                  :string(255)
#  profile_image_url            :string(255)
#  url                          :string(255)
#  protected                    :boolean
#  profile_background_color     :string(255)
#  profile_sidebar_fill_color   :string(255)
#  profile_link_color           :string(255)
#  profile_sidebar_border_color :string(255)
#  profile_text_color           :string(255)
#  profile_background_image_url :string(255)
#  profile_background_tiled     :boolean
#  friends_count                :integer
#  statuses_count               :integer
#  followers_count              :integer
#  favourites_count             :integer
#  utc_offset                   :integer
#  time_zone                    :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#


require 'test_helper'

# note: uses TwitterAuth's GenericUser as a base
class UserTest < ActiveSupport::TestCase
  setup do
    @user = Factory(:user)
  end

  should_validate_presence_of :login, :twitter_id
  should_validate_uniqueness_of :login
  should_validate_uniqueness_of :twitter_id, :message => "ID has already been taken."
end
