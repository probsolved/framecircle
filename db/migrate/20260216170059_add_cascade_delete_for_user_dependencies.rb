class AddCascadeDeleteForUserDependencies < ActiveRecord::Migration[7.1]
  def change
    # group_memberships.user_id -> users.id
    remove_foreign_key :group_memberships, :users
    add_foreign_key :group_memberships, :users, on_delete: :cascade

    # submissions.user_id -> users.id
    remove_foreign_key :submissions, :users
    add_foreign_key :submissions, :users, on_delete: :cascade

    # comments.user_id -> users.id
    remove_foreign_key :comments, :users
    add_foreign_key :comments, :users, on_delete: :cascade

    # votes.user_id -> users.id
    remove_foreign_key :votes, :users
    add_foreign_key :votes, :users, on_delete: :cascade

    # group_invitations.invited_by_id -> users.id
    remove_foreign_key :group_invitations, column: :invited_by_id
    add_foreign_key :group_invitations, :users, column: :invited_by_id, on_delete: :cascade

    # IMPORTANT: Do NOT cascade groups.owner_id. We transfer ownership in the controller.
    # (leave fk_rails_5447bdb9c5 alone)
  end
end
