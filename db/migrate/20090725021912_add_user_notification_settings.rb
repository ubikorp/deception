class AddUserNotificationSettings < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_start, :boolean, :default => true
    add_column :users, :notify_finish, :boolean, :default => true
    add_column :users, :notify_period_change, :boolean, :default => true
    add_column :users, :notify_death, :boolean, :default => true
    add_column :users, :notify_quit, :boolean, :default => true
    add_column :users, :notify_reply, :boolean, :default => true
  end

  def self.down
    remove_column :users, :notify_start
    remove_column :users, :notify_finish
    remove_column :users, :notify_period_change
    remove_column :users, :notify_death
    remove_column :users, :notify_quit
    remove_column :users, :notify_reply
  end
end
