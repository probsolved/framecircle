class InvitationsController < ApplicationController
  # You only want auth for creating invites; viewing invite landing page should work logged out.
  before_action :authenticate_user!, only: [ :create ]
  before_action :set_group, only: [ :create ]

  # POST /groups/:group_slug/invitations
  def create
  unless owner_or_admin?(@group)
    return redirect_to group_path(@group), alert: "Not allowed."
  end

  invitation = GroupInvitation.create!(group: @group, invited_by: current_user)

  invitation.regenerate_token if invitation.token.blank?
  invitation.save! if invitation.changed?

  url = invitation_url(invitation.token) # /invitations/:token
  redirect_to group_manage_path(@group), notice: "Invite link created: #{url}"
  end

# GET /invitations/:token
# GET /invitations/:token
def show
  @invitation = GroupInvitation.find_by!(token: params[:token])
  @group = @invitation.group

  if user_signed_in?
    accept_invite!(@invitation, current_user)
    redirect_to group_path(@group), notice: "You joined #{@group.name}."
  else
    # 1) Tell Devise where to return after sign-in
    store_location_for(:user, invitation_path(@invitation.token))

    # 2) Optional: also keep token if you want to show “joining…” on the login page
    session[:pending_invite_token] = @invitation.token

    redirect_to new_user_session_path, notice: "Sign in (or create an account) to join #{@group.name}."
  end
end

def legacy_show
  invitation = GroupInvitation.find_by(id: params[:id])

  if invitation&.token.present?
    redirect_to invitation_path(invitation.token), status: :moved_permanently
  else
    raise ActiveRecord::RecordNotFound
  end
end

def accept
  @invitation = GroupInvitation.find_by!(token: params[:token])
  @group = @invitation.group

  authenticate_user!
  accept_invite!(@invitation, current_user)

  redirect_to group_path(@group), notice: "You joined #{@group.name}."
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

    # Mark accepted if your model has it
    invitation.update!(accepted_at: Time.current) if invitation.respond_to?(:accepted_at)
  end
end
