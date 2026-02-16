class WeeksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :require_member!
  before_action :set_week, only: [ :show ]

  def show
    @submissions = @week.submissions.includes(:user, :votes, comments: [ :user, :comment_kudos ])
  end

  def create
    # If your Week is created from some form params, keep your existing fields.
    @week = @group.weeks.new(week_params)

    if @week.save
      redirect_to group_week_path(@group, @week), notice: "Week created."
    else
      redirect_back fallback_location: group_path(@group),
                    alert: @week.errors.full_messages.to_sentence
    end
  end

  private

  def set_group
    @group = Group.find_by!(slug: params[:group_slug])
  end

  def set_week
    @week = @group.weeks.find(params[:id])
  end

  # ✅ THIS is the key change
  def require_member!
    return if current_user.admin?
    return if @group.owner_id == current_user.id

    membership = @group.group_memberships.find_by(user_id: current_user.id)
    is_active_member = membership.present? && membership.status.to_s == "active"

    redirect_to group_path(@group), alert: "You must be a member of this group." unless is_active_member
  end

  def week_params
    # Keep whatever you already allow.
    # If you create weeks automatically (no fields), you can just return {}.
    params.fetch(:week, {}).permit(:title, :starts_on, :ends_on)
  end
end
