class Invitation < ApplicationRecord
  belongs_to :group
  belongs_to :inviter, class_name: "User"

  validates :token, presence: true, uniqueness: true

  has_secure_token :token
end
