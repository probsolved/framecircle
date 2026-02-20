# db/migrate/xxxxxx_add_last_seen_at_to_group_memberships.rb
class AddLastSeenAtToGroupMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :group_memberships, :last_seen_at, :datetime
    add_index :group_memberships, :last_seen_at
  end
end
