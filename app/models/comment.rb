class Comment < ApplicationRecord
  after_create_commit :notify_group_members
  after_create_commit :track_activity

  belongs_to :submission
  belongs_to :user

  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :comment_kudos, dependent: :destroy

  validates :body, presence: true
  validates :photo_index, inclusion: { in: 0..2 }, allow_nil: true

  private

  def notify_group_members
    week  = submission.week
    group = week.group

    recipient_ids = group.group_memberships
                         .where(status: "active")
                         .where.not(user_id: user_id)
                         .pluck(:user_id)

    recipient_ids.each do |rid|
      Notification.create!(
        recipient_id: rid,
        actor_id: user_id,
        group: group,
        week: week,
        submission: submission,
        comment: self,
        kind: "new_comment"
      )
    end
  end

  def track_activity
    week  = submission.week
    group = week.group

    Activity.create!(
      group: group,
      actor: user,
      action: parent_id.present? ? "comment.reply_created" : "comment.created",
      subject: self,
      target: submission,
      occurred_at: created_at
    )
  end
end
