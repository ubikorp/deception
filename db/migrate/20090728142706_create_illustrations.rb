class CreateIllustrations < ActiveRecord::Migration
  def self.up
    create_table :illustrations do |t|
      t.string :artist_name
      t.string :artist_url
      t.string :art_file_name
      t.string :art_content_type
      t.string :art_file_size
      t.string :art_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :illustrations
  end
end
