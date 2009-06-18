class PlayersAreDead < ActiveRecord::Migration
  def self.up
    add_column :players, :dead, :boolean, :default => false
  end

  def self.down
    remove_column :players, :dead
  end
end
