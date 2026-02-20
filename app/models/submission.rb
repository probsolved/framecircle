# app/models/submission.rb
class Submission < ApplicationRecord
  FEEDBACK_FOCUS_OPTIONS = %w[
    composition
    lighting
    color
    story
    editing
  ].freeze

  after_create_commit :notify_group_members_of_submission

  belongs_to :week
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy

  has_many_attached :photos

  before_validation do
    self.feedback_focus = Array(feedback_focus).reject(&:blank?)
  end

  validates :user_id, uniqueness: { scope: :week_id }
  validate :max_three_photos
  validate :feedback_focus_values_are_valid

  def locked?
    locked_at.present?
  end

  def photo_count
    photos.attachments.size
  end

  def feedback_focus_labels
    return [] if feedback_focus.blank?

    map = {
      "composition" => "Composition",
      "lighting"    => "Lighting",
      "color"       => "Color",
      "story"       => "Story / Mood",
      "editing"     => "Editing / Post"
    }
    feedback_focus.map { |k| map[k] || k.to_s.humanize }
  end

  private

  def notify_group_members_of_submission
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
        submission: self,
        kind: "new_submission"
      )
    end
  end

  def max_three_photos
    return unless photos.attachments.size > 3
    errors.add(:photos, "maximum is 3 per week")
  end

  def feedback_focus_values_are_valid
    return if feedback_focus.blank?

    invalid = feedback_focus - FEEDBACK_FOCUS_OPTIONS
    errors.add(:feedback_focus, "includes invalid options: #{invalid.join(', ')}") if invalid.any?
  end
end
