class Week < ApplicationRecord
  belongs_to :group
  has_many :submissions, dependent: :destroy

  enum :status, { open: 0, closed: 1 }

  validates :title, :starts_on, :ends_on, presence: true
  validate :ends_after_starts

  def active?
    open? && Date.current.between?(starts_on, ends_on)
  end

  private

  def ends_after_starts
    return if starts_on.blank? || ends_on.blank?
    errors.add(:ends_on, "must be after starts_on") if ends_on < starts_on
  end
end
