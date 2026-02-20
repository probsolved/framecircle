class CommentKudo < ApplicationRecord
  KINDS = %w[helpful insightful encouraging].freeze

  belongs_to :comment
  belongs_to :user

  validates :kind, inclusion: { in: KINDS }

  after_create_commit :track_activity

  private

  def track_activity
    week  = comment.submission.week
    group = week.group

    Activity.create!(
      group: group,
      actor: user,
      action: "comment_kudo.created",
      subject: self,
      target: comment,
      occurred_at: created_at
    )
  end
end
