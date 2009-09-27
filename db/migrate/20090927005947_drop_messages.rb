class DropMessages < ActiveRecord::Migration
  def self.up
    drop_table :messages
  end

  def self.down
    create_table :messages do |t|
      t.integer  :game_id
      t.string   :text
      t.datetime :delivered_at
      t.string   :type
      t.integer  :from_user_id
      t.integer  :to_user_id
      t.integer  :status_id
      t.timestamps
    end
  end
end
