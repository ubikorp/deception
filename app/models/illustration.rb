# == Schema Information
#
# Table name: illustrations
#
#  id               :integer         not null, primary key
#  artist_name      :string(255)
#  artist_url       :string(255)
#  art_file_name    :string(255)
#  art_content_type :string(255)
#  art_file_size    :string(255)
#  art_updated_at   :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class Illustration < ActiveRecord::Base
  has_attached_file :art,
                    :styles => { :ico => '48x48', :normal => '550x500' },
                    :content_type => ['image/png', 'image/jpg'],
                    :whiny_thumbnails => true

  validates_attachment_presence :art
  validates_attachment_size :art, :less_than => 1.megabyte

  validates_presence_of :artist_name, :artist_url
end
