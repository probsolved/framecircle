class AddInvitedByForeignKeyToGroupInvitations < ActiveRecord::Migration[7.1]
  def change
    add_index :group_invitations, :invited_by_id
    add_foreign_key :group_invitations, :users, column: :invited_by_id
  end
end
