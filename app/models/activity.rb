class Activity < ApplicationRecord
  belongs_to :group
  belongs_to :actor, class_name: "User"

  belongs_to :subject, polymorphic: true
  belongs_to :target, polymorphic: true, optional: true

  validates :action, presence: true
  validates :occurred_at, presence: true

  scope :recent, -> { order(occurred_at: :desc) }
end
