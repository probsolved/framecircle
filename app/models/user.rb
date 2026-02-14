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
end
