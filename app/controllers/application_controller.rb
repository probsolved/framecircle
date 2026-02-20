class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :require_terms_acceptance

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :family_friendly_terms ])
  end

  def after_sign_in_path_for(resource)
    token = session.delete(:pending_invite_token)
    return invitation_path(token) if token.present?

    super
  end

  private

  def require_terms_acceptance
  return unless user_signed_in?
  return if current_user.family_friendly_terms_accepted?
  return if devise_controller?
  return if controller_name == "terms_acceptances"

  # ✅ Don’t overwrite an existing stored location (like an invite link)
  store_location_for(:user, request.fullpath) unless stored_location_for(:user).present?

  redirect_to terms_acceptance_path
  end
end
