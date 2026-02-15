class GroupMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_membership, only: [ :destroy, :update ]

  def update
    # Only allow site admins, group owner, or group admins
    unless can_manage_members?(@group)
      return redirect_back fallback_location: group_members_path(@group),
                           alert: "Not authorized."
    end

    if @membership.update(membership_params)
      redirect_back fallback_location: group_members_path(@group),
                    notice: "Member updated."
    else
      redirect_back fallback_location: group_members_path(@group),
                    alert: @membership.errors.full_messages.to_sentence
    end
  end

  private

  def set_group
    @group = Group.find_by!(slug: params[:group_slug])
  end

  def set_membership
    @membership = @group.memberships.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:role)
  end

  def can_manage_members?(group)
    return true if current_user.admin?
    return true if current_user.id == group.owner_id
    group.memberships.exists?(user_id: current_user.id, role: "admin")
  end
end
