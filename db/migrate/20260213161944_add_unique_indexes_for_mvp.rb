class AddUniqueIndexesForMvp < ActiveRecord::Migration[7.1]
  def change
    add_index :groups, :slug, unique: true

    add_index :group_memberships, [ :group_id, :user_id ], unique: true
    add_index :submissions, [ :week_id, :user_id ], unique: true
    add_index :votes, [ :submission_id, :user_id ], unique: true

    add_index :group_invitations, :token, unique: true
  end
end
