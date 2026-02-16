class Comment < ApplicationRecord
  belongs_to :submission
  belongs_to :user

  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :comment_kudos, dependent: :destroy

  validates :body, presence: true
  validates :photo_index, inclusion: { in: 0..2 }, allow_nil: true
end
