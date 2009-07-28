class AddTitleToIllustrations < ActiveRecord::Migration
  def self.up
    add_column :illustrations, :title, :string
  end

  def self.down
    remove_column :illustrations, :title
  end
end
