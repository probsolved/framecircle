class Group < ApplicationRecord
def to_param
  slug
end


  belongs_to :owner, class_name: "User"

  has_many :group_memberships, dependent: :destroy
  has_many :members, through: :group_memberships, source: :user
  has_many :users, through: :group_memberships
  has_many :group_invitations, dependent: :destroy
  has_many :weeks, dependent: :destroy
  has_many :group_invitations, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :public, inclusion: { in: [ true, false ], message: "must be selected" }

  before_validation :ensure_slug

  scope :publicly_visible, -> { where(public: true) }

  def member_count
    group_memberships.where(status: "active").count
  end

  private

  def ensure_slug
    self.slug = name.to_s.parameterize.presence || "group-#{SecureRandom.hex(4)}" if slug.blank?
  end
end
