class AddMaxPlayersSetting < ActiveRecord::Migration
  def self.up
    rename_column :games, :player_threshold, :min_players
    add_column    :games, :max_players, :integer
  end

  def self.down
    rename_column :games, :min_players, :player_threshold
    remove_column :games, :max_players
  end
end
