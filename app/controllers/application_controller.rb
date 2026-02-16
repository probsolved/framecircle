class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :require_terms_acceptance

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :family_friendly_terms ])
  end

  private

  def require_terms_acceptance
    return unless user_signed_in?
    return if current_user.family_friendly_terms_accepted?
    return if devise_controller?
    return if controller_name == "terms_acceptances"

    redirect_to terms_acceptance_path
  end
end
