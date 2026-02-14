class GroupMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :require_membership!

  def index
    @memberships = @group.group_memberships.includes(:user).order("users.email ASC")
  end

  private

  def set_group
    @group = Group.find_by!(slug: params[:group_slug])
  end

  def require_membership!
    return if @group.owner_id == current_user.id
    return if GroupMembership.exists?(group: @group, user: current_user)

    redirect_to groups_path, alert: "You must be a member of this group to view the member list."
  end
end
