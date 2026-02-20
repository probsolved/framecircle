class GroupMembership < ApplicationRecord
  belongs_to :group
  belongs_to :user

enum :role, { member: 0, admin: 1 }
enum :status, { active: 0, invited: 1, removed: 2 }

  validates :user_id, uniqueness: { scope: :group_id }

  def unread_activity_count
    since = last_seen_at || Time.at(0)
    group.activities.where("occurred_at > ?", since).count
  end
end
