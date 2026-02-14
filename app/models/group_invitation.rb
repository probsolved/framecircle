class GroupInvitation < ApplicationRecord
  belongs_to :group
  belongs_to :invited_by, class_name: "User", optional: true

  validates :token, presence: true, uniqueness: true
  before_validation :ensure_token

  def accepted?
    accepted_at.present?
  end

  private

  def ensure_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end
end
