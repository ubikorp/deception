class AddGameSettings < ActiveRecord::Migration
  def self.up
    add_column :games, :invite_only,      :boolean
    add_column :games, :player_threshold, :integer
    add_column :games, :period_length,    :integer
  end

  def self.down
    remove_column :games, :invite_only
    remove_column :games, :player_threshold
    remove_column :games, :period_length
  end
end
