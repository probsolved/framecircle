class WeeksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :require_member!
  before_action :set_week, only: [ :show ]

  def show
    @submissions = @week.submissions.includes(:user, :votes, comments: [ :user, :comment_kudos ])

    # Mark "week-scoped" notifications as read when the user views the week.
    Notification.unread
                .where(recipient: current_user, week: @week)
                .update_all(read_at: Time.current)
  end

  def create
    @week = @group.weeks.new(week_params)

    if @week.save
      redirect_to group_week_path(@group, @week), notice: "Week created."
      return
    end

    redirect_back fallback_location: group_path(@group),
                  alert: @week.errors.full_messages.to_sentence

  rescue ActiveRecord::RecordNotUnique
    # DB uniqueness (group_id, starts_on, ends_on) caught a duplicate (or race condition)
    existing = @group.weeks.find_by(starts_on: week_params[:starts_on], ends_on: week_params[:ends_on])

    if existing
      redirect_to group_week_path(@group, existing),
                  alert: "That week already exists — opened the existing week."
    else
      redirect_to group_path(@group), alert: "That week already exists."
    end
  end

  private

  def set_group
    @group = Group.find_by!(slug: params[:group_slug])
  end

  def set_week
    @week = @group.weeks.find(params[:id])
  end

  def require_member!
    return if current_user.admin?
    return if @group.owner_id == current_user.id

    membership = @group.group_memberships.find_by(user_id: current_user.id)
    is_active_member = membership.present? && membership.status.to_s == "active"

    redirect_to group_path(@group), alert: "You must be a member of this group." unless is_active_member
  end

  def week_params
    params.fetch(:week, {}).permit(:title, :starts_on, :ends_on)
  end
end
