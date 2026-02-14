# app/controllers/invitations_controller.rb
class InvitationsController < ApplicationController
  before_action :authenticate_user!, only: [ :create ]
  before_action :set_group, only: [ :create ]

  def create
    unless owner_or_admin?(@group)
      return redirect_to group_path(@group), alert: "Not allowed."
    end

    invitation = @group.group_invitations.create!(
      invited_by: current_user
      # token is auto-set by GroupInvitation#ensure_token
    )

    url = group_invitation_url(invitation) # full URL to /group_invitations/:id
    redirect_to group_manage_path(@group), notice: "Invite link created: #{url}"
  end

  def show
    @invitation = GroupInvitation.find(params[:id])
    @group = @invitation.group

    if user_signed_in?
      accept_invite!(@invitation, current_user)
      redirect_to group_path(@group), notice: "You joined #{@group.name}."
    else
      render :show   # 👈 this is what prevents “fall through”
    end
  end

  private

  def set_group
    @group = Group.find_by!(slug: params[:group_slug])
  end

  def owner_or_admin?(group)
    return true if group.owner_id == current_user.id
    m = GroupMembership.find_by(group: group, user: current_user)
    m&.role.to_s == "admin" && (m.respond_to?(:status) ? m.status.to_s == "active" : true)
  end

  def accept_invite!(invitation, user)
    GroupMembership.find_or_create_by!(group: invitation.group, user: user) do |m|
      m.role = :member if m.respond_to?(:role)
      m.status = :active if m.respond_to?(:status)
    end
  end
end
