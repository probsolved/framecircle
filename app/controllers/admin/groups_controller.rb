class Admin::GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @groups = Group.includes(:owner).order(created_at: :desc)
  end

  def destroy
    group = Group.find(params[:id])
    group.destroy!
    redirect_to admin_groups_path, notice: "Group deleted."
  rescue ActiveRecord::RecordNotDestroyed => e
    redirect_to admin_groups_path, alert: e.message
  end

  private

  def require_admin!
    redirect_to root_path, alert: "Not authorized." unless current_user.admin?
  end
end
