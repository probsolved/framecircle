class GroupInvitation < ApplicationRecord
  belongs_to :group
  belongs_to :invited_by, class_name: "User", optional: true

  has_secure_token :token

  validates :token, presence: true, uniqueness: true

  def accepted?
    accepted_at.present?
  end

  def to_param
    token
  end
end
