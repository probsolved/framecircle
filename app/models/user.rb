# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  has_one_attached :avatar

# ============================
# Associations
# ============================

has_many :owned_groups,
        class_name: "Group",
        foreign_key: :owner_id,
        inverse_of: :owner

has_many :group_memberships, dependent: :destroy
has_many :groups, through: :group_memberships

has_many :comment_kudos, dependent: :destroy

has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
has_many :sent_notifications, class_name: "Notification", foreign_key: :actor_id, dependent: :nullify


  # ============================
  # Validations
  # ============================

  validates :display_name, length: { maximum: 50 }, allow_blank: true
  validates :location, length: { maximum: 500 }, allow_blank: true
  validates :frames_username, length: { maximum: 100 }, allow_blank: true

  # Family-friendly terms (virtual attr for signup checkbox)
  attr_accessor :family_friendly_terms
  validates :family_friendly_terms, acceptance: true, on: :create

  # ============================
  # Callbacks
  # ============================

  before_create :stamp_family_friendly_terms

  # ============================
  # Instance methods
  # ============================

  def display_name_or_email
    display_name.presence || email
  end

  def frames_profile_url
    return if frames_username.blank?
    "https://52frames.com/photographer/#{frames_username}"
  end

  def family_friendly_terms_accepted?
    family_friendly_terms_accepted_at.present?
  end

  # ============================
  # Private
  # ============================

  private

  def stamp_family_friendly_terms
    self.family_friendly_terms_accepted_at = Time.current
  end

  def ensure_not_group_owner
    return unless owned_groups.exists?

    errors.add(:base, "User owns one or more groups and cannot be deleted.")
    throw :abort
  end
end
