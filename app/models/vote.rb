class Vote < ApplicationRecord
  belongs_to :submission
  belongs_to :user

  validates :user_id, uniqueness: { scope: :submission_id }
  validates :photo_index, inclusion: { in: 0..2 }

  validate :cannot_vote_for_missing_photo

  private

  def cannot_vote_for_missing_photo
    return unless submission&.photos
    if submission.photos.attachments.size <= photo_index
      errors.add(:photo_index, "refers to a missing photo")
    end
  end
end
