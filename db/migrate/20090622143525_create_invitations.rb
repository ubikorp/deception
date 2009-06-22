class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.integer :game_id
      t.string  :twitter_login
      t.timestamps
    end

    add_column :games, :short_code, :string
    add_column :games, :owner_id, :integer
  end

  def self.down
    drop_table :invitations
    remove_column :games, :short_code
    remove_column :games, :owner_id
  end
end
