class AddMessageTypes < ActiveRecord::Migration
  def self.up
    add_column :messages, :type, :string
    add_column :messages, :from_user_id, :integer
    add_column :messages, :to_user_id, :integer

    remove_column :messages, :target
  end

  def self.down
    add_column :messages, :target, :string

    remove_column :messages, :from_user_id
    remove_column :messages, :to_user_id
    remove_column :messages, :type
  end
end
