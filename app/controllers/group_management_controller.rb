class GroupManagementController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :require_admin!

  def show
    @memberships = @group.group_memberships.includes(:user).order(:created_at)
    @new_member = GroupMembership.new
    @invitations = @group.group_invitations.order(created_at: :desc)
  end

  private

  def set_group
    @group = Group.find_by!(slug: params[:group_slug])
  end

  def require_admin!
    return if @group.owner_id == current_user.id

    membership = GroupMembership.find_by(group: @group, user: current_user)
    allowed = membership&.role.to_s == "admin" && membership&.status.to_s == "active"
    redirect_to group_path(@group), alert: "You don’t have permission to manage this group." unless allowed
  end
end
