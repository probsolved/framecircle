# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  validates :display_name, length: { maximum: 50 }, allow_blank: true
  validates :location, length: { maximum: 500 }, allow_blank: true
  validates :frames_username, length: { maximum: 100 }, allow_blank: true

  def name_for_display
    display_name.presence || email
  end

  def frames_profile_url
    return if frames_username.blank?
    "https://52frames.com/photographer/#{frames_username}"
  end

  attr_accessor :family_friendly_terms

  validates :family_friendly_terms, acceptance: true, on: :create

  before_create :stamp_family_friendly_terms

  def family_friendly_terms_accepted?
    family_friendly_terms_accepted_at.present?
  end

  private

  def stamp_family_friendly_terms
    self.family_friendly_terms_accepted_at = Time.current
  end
end
