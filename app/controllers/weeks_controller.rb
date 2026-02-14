class WeeksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group

  def show
  @week = @group.weeks.find(params[:id])

  @submissions = @week.submissions
    .includes(:user, :votes, :comments, photos_attachments: :blob)
    .order(created_at: :asc)
  end


  def create
  today  = Date.current
  start  = today.beginning_of_week(:monday)
  ending = today.end_of_week(:sunday)

  title = params.dig(:week, :title).presence || "Week of #{start.strftime("%b %-d, %Y")}"

  # If this week already exists for the group, reuse it
  existing = @group.weeks.find_by(starts_on: start, ends_on: ending)

  if existing.present?
    # Optional: if you want to allow title edits when user enters one
    if params.dig(:week, :title).present? && existing.title != title
      existing.update(title: title)
    end

    return redirect_to group_week_path(@group, existing), notice: "Week already exists — opened it."
  end

  @week = @group.weeks.new(
    title: title,
    starts_on: start,
    ends_on: ending,
    status: :open
  )

  if @week.save
    redirect_to group_week_path(@group, @week), notice: "Week created."
  else
    redirect_to group_path(@group), alert: @week.errors.full_messages.to_sentence
  end
  end


  private

  def set_group
    @group = Group.find_by!(slug: params[:group_slug])
  end
end
