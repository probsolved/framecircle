class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User"

  belongs_to :group, optional: true
  belongs_to :week, optional: true
  belongs_to :submission, optional: true
  belongs_to :comment, optional: true

  scope :unread, -> { where(read_at: nil) }
end
