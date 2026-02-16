class CommentKudo < ApplicationRecord
  KINDS = %w[helpful insightful encouraging].freeze

  belongs_to :comment
  belongs_to :user

  validates :kind, inclusion: { in: KINDS }
end
