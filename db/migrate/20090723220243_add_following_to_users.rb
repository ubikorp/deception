class AddFollowingToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :following, :boolean, :default => false
  end

  def self.down
    remove_column :users, :following
  end
end
