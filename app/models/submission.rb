class Submission < ApplicationRecord
  belongs_to :week
  belongs_to :user

  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy

  has_many_attached :photos

  validates :user_id, uniqueness: { scope: :week_id }
  validate :max_three_photos

  def locked?
    locked_at.present?
  end

  def photo_count
    photos.attachments.size
  end

  private

  def max_three_photos
    return unless photos.attachments.size > 3
    errors.add(:photos, "maximum is 3 per week")
  end
end
