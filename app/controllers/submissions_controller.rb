class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_week

  def show
    @submission = Submission.find_by(week: @week, user: current_user) ||
                  Submission.new(week: @week, user: current_user)
  end

  def create
    @submission = Submission.new(submission_params)
    @submission.week = @week
    @submission.user = current_user

    if @submission.save
      redirect_to group_week_path(@group, @week), notice: "Submission saved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def update
  @submission = Submission.find_by!(week: @week, user: current_user)

  # Update caption first (no attachment changes yet)
  @submission.assign_attributes(submission_params.except(:photos))

  # Append new photos (do NOT replace existing)
  new_photos = submission_params[:photos].presence || []

  if new_photos.any?
    if @submission.photos.attachments.size + new_photos.size > 3
      @submission.errors.add(:photos, "maximum is 3 per week")
      return render :show, status: :unprocessable_entity
    end

    @submission.photos.attach(new_photos)
  end

  if @submission.save
    redirect_to group_week_submission_path(@group, @week), notice: "Submission updated."
  else
    render :show, status: :unprocessable_entity
  end
  end


  private

  def set_group
    @group = Group.find_by!(slug: params[:group_slug])
  end

  def set_week
    @week = @group.weeks.find(params[:week_id])
  end

  def submission_params
    params.require(:submission).permit(:caption, photos: [])
  end
end
