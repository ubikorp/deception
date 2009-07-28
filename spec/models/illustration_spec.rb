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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Illustration do
  it { should validate_presence_of(:artist_name) }
  it { should validate_presence_of(:artist_url) }
  it { should have_attached_file(:art, :styles => { :ico => "48x48", :normal => "550x500" }) }
  it { should validate_attachment_presence(:art) }
  it { should validate_attachment_size(:art, :less_than => 1.megabyte) }
  it { should validate_attachment_content_type(:art, :allows => ["image/png", "image/jpg"]) }
end
