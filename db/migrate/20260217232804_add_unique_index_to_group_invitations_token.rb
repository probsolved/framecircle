class AddUniqueIndexToGroupInvitationsToken < ActiveRecord::Migration[8.0]
  def change
    add_index :group_invitations, :token, unique: true
  end
end
