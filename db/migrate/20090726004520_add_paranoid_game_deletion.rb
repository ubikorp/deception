class AddParanoidGameDeletion < ActiveRecord::Migration
  def self.up
    add_column :games, :deleted_at, :datetime
  end

  def self.down
    remove_column :games, :deleted_at
  end
end
