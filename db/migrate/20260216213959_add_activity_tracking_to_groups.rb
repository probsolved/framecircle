class AddActivityTrackingToGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :last_activity_at, :datetime
    add_column :group_memberships, :last_viewed_at, :datetime
    add_index  :groups, :last_activity_at
    add_index  :group_memberships, :last_viewed_at
  end
end
