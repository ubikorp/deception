class CreatePlayers < ActiveRecord::Migration
  def self.up
    create_table :players do |t|
      t.integer :user_id
      t.integer :game_id
      t.string  :type
      t.timestamps
    end

    add_column :events, :source_player_id, :integer
    add_column :events, :target_player_id, :integer
  end

  def self.down
    remove_column :events, :source_player_id
    remove_column :events, :target_player_id
    drop_table :players
  end
end
