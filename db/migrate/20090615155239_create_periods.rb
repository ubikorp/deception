class CreatePeriods < ActiveRecord::Migration
  def self.up
    create_table :periods do |t|
      t.integer :game_id
      t.timestamps
    end

    add_column :events, :period_id, :integer
    remove_column :events, :game_id
  end

  def self.down
    drop_table :periods

    add_column :events, :game_id, :integer
    remove_column :events, :period_id
  end
end
