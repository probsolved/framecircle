class GroupMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_membership, only: [ :destroy, :update ]

  # POST /groups/:group_slug/memberships
  # Used by "Join Group" (and also by invite acceptance if you reuse it)
  def create
    membership = @group.group_memberships.find_or_initialize_by(user: current_user)

    # If you have status/role columns, set sane defaults
    membership.status = "active" if membership.respond_to?(:status) && membership.status.blank?
    membership.role   = "member" if membership.respond_to?(:role) && membership.role.blank?

    if membership.save
      redirect_to group_path(@group), notice: "You joined #{@group.name}."
    else
      redirect_to discover_groups_path, alert: membership.errors.full_messages.to_sentence
    end
  end

  # PATCH /groups/:group_slug/memberships/:id
  def update
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

  # DELETE /groups/:group_slug/memberships/:id
  #
  # Behavior:
  # - If current user is deleting THEIR OWN membership: allow (leave group), unless they're the owner.
  # - If admin/owner/group-admin: allow removing someone else, unless target is owner.
  def destroy
    is_self = (@membership.user_id == current_user.id)

    if @membership.user_id == @group.owner_id
      return redirect_back fallback_location: group_members_path(@group),
                           alert: "You can’t remove the group owner."
    end

    unless is_self || can_manage_members?(@group)
      return redirect_back fallback_location: group_members_path(@group),
                           alert: "Not authorized."
    end

    @membership.destroy

    if is_self
      redirect_to discover_groups_path, notice: "You left #{@group.name}."
    else
      redirect_back fallback_location: group_members_path(@group),
                    notice: "Member removed."
    end
  end

  private

  def set_group
    @group = Group.find_by!(slug: params[:group_slug])
  end

  def set_membership
    @membership = @group.group_memberships.find(params[:id])
  end

  def membership_params
    # Add :status here only if you actually want admins to change it via UI
    params.require(:membership).permit(:role)
  end

  def can_manage_members?(group)
    return true if current_user.admin?
    return true if current_user.id == group.owner_id

    group.group_memberships.exists?(user_id: current_user.id, role: "admin")
  end
end
