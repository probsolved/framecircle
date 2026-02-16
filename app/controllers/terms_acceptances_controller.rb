class TermsAcceptancesController < ApplicationController
  before_action :authenticate_user!

  def show
    redirect_to root_path if current_user.family_friendly_terms_accepted?
  end

  def update
    if params[:family_friendly_terms] == "1"
      current_user.update!(family_friendly_terms_accepted_at: Time.current)
      redirect_to root_path, notice: "Thanks — you’re all set."
    else
      flash.now[:alert] = "You must agree to continue."
      render :show, status: :unprocessable_entity
    end
  end
end
