class AddInvitedBy < ActiveRecord::Migration
  def self.up
    add_column :invitations, :invited_by_id, :integer
  end

  def self.down
    remove_column :invitations, :invited_by_id
  end
end
