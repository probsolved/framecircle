class GroupManagementController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :require_admin!

  def show
    @memberships = @group.group_memberships.includes(:user).order(:created_at)
    @new_member = GroupMembership.new
    @invitations = @group.group_invitations.order(created_at: :desc)
  end

  def update
    if @group.update(group_params)
      redirect_to group_manage_path(@group), notice: "Group settings updated."
    else
      redirect_to group_manage_path(@group), alert: @group.errors.full_messages.to_sentence
    end
  end

  private

  def set_group
    @group = Group.find_by!(slug: params[:group_slug])
  end

  def require_admin!
    return if current_user.admin?
    return if @group.owner_id == current_user.id

    membership = GroupMembership.find_by(group: @group, user: current_user)
    allowed = membership&.role.to_s == "admin" && membership&.status.to_s == "active"
    redirect_to group_path(@group), alert: "You don’t have permission to manage this group." unless allowed
  end

  def group_params
    params.require(:group).permit(:public)
  end
end
