class SubmissionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :set_week
  before_action :set_submission, only: [ :show, :update ]

  def show
    # @submission set in before_action
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
    # Update caption first (no attachment changes yet)
    @submission.assign_attributes(submission_params.except(:photos))

    # Append new photos (do NOT replace existing)
    new_photos = Array(submission_params[:photos]).reject(&:blank?)

    if new_photos.any?
      existing_count = @submission.photos.attachments.size
      if existing_count + new_photos.size > 3
        @submission.errors.add(:photos, "maximum is 3 per week")
        return render :show, status: :unprocessable_entity
      end

      begin
        @submission.photos.attach(new_photos)
      rescue Aws::S3::Errors::InvalidRequest => e
        # Typical with Cloudflare R2 when multiple checksums are sent
        Rails.logger.error("ActiveStorage S3/R2 attach failed: #{e.class}: #{e.message}")
        @submission.errors.add(:photos, "upload failed (storage rejected the request). Try again in a moment.")
        return render :show, status: :unprocessable_entity
      rescue => e
        Rails.logger.error("ActiveStorage attach failed: #{e.class}: #{e.message}")
        @submission.errors.add(:photos, "upload failed. Please try again.")
        return render :show, status: :unprocessable_entity
      end
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

  def set_submission
    @submission =
      Submission.find_by(week: @week, user: current_user) ||
      Submission.new(week: @week, user: current_user)
  end

  def submission_params
    params.require(:submission).permit(:caption, photos: [])
  end
end
