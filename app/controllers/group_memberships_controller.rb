class GroupMembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :require_admin!

  def create
    email = params.dig(:group_membership, :email).to_s.strip.downcase
    user = User.find_by(email: email)

    unless user
      return redirect_to group_manage_path(@group), alert: "No user found with that email."
    end

    membership = GroupMembership.find_or_initialize_by(group: @group, user: user)
    membership.role = membership.role.presence || "member"
    membership.status = "active" if membership.respond_to?(:status) # if you have status enum

    if membership.save
      redirect_to group_manage_path(@group), notice: "Added #{user.email}."
    else
      redirect_to group_manage_path(@group), alert: membership.errors.full_messages.to_sentence
    end
  end

  def destroy
    membership = @group.group_memberships.find(params[:id])

    if membership.user_id == @group.owner_id
      return redirect_to group_manage_path(@group), alert: "You can’t remove the group owner."
    end

    membership.destroy
    redirect_to group_manage_path(@group), notice: "Member removed."
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
