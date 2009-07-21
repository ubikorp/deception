class AddStatusIdToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :status_id, :integer
  end

  def self.down
    remove_column :messages, :status_id
  end
end
