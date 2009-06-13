class AddGameState < ActiveRecord::Migration
  def self.up
    add_column :games, :state, :string
  end

  def self.down
    remove_column :games, :state
  end
end
