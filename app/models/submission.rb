class Submission < ApplicationRecord
  FEEDBACK_FOCUS_OPTIONS = %w[
    composition
    lighting
    color
    story
    editing
  ].freeze

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

  def locked?
    locked_at.present?
  end

  def photo_count
    photos.attachments.size
  end

  validate :feedback_focus_values_are_valid

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
