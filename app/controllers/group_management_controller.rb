# app/controllers/group_management_controller.rb
class GroupManagementController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :require_admin!

  def show
    @memberships  = @group.group_memberships.includes(:user).order(:created_at)
    @new_member   = GroupMembership.new
    @invitations  = @group.group_invitations.order(created_at: :desc)
  end

  # PATCH /groups/:group_slug/transfer_ownership/:user_id
  def transfer_ownership
    new_owner = User.find(params[:user_id])

    # Must already be an ACTIVE member of this group
    new_owner_membership = GroupMembership.find_by(group: @group, user: new_owner)
    unless new_owner_membership&.status.to_s == "active"
      return redirect_to group_members_path(@group), alert: "That user must be an active member of this group."
    end

    ActiveRecord::Base.transaction do
      # Transfer ownership
      @group.update!(owner_id: new_owner.id)

      # Ensure the new owner is an admin (and active)
      new_owner_membership.update!(role: "admin", status: "active") if new_owner_membership

      # Ensure the previous owner remains an admin (and active)
      previous_owner_membership = GroupMembership.find_by(group: @group, user_id: current_user.id)
      if previous_owner_membership
        previous_owner_membership.update!(role: "admin", status: "active")
      end
    end

    redirect_to group_members_path(@group), notice: "Ownership transferred to #{new_owner.respond_to?(:display_name_or_email) ? new_owner.display_name_or_email : (new_owner.display_name.presence || new_owner.email)}."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    redirect_to group_members_path(@group), alert: "Could not transfer ownership: #{e.message}"
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
