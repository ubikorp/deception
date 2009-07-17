class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.integer  :game_id
      t.string   :target
      t.string   :text
      t.datetime :delivered_at
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
