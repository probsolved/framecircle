class VotesController < ApplicationController
  before_action :authenticate_user!

  def create
    submission = Submission.find(params[:submission_id])

    vote = submission.votes.find_or_initialize_by(user: current_user)
    vote.photo_index = params.require(:vote).fetch(:photo_index).to_i

    if vote.save
      redirect_back fallback_location: root_path, notice: "Vote saved."
    else
      redirect_back fallback_location: root_path, alert: vote.errors.full_messages.to_sentence
    end
  end

  def update
    submission = Submission.find(params[:submission_id])
    vote = submission.votes.find_by!(user: current_user)

    vote.photo_index = params.require(:vote).fetch(:photo_index).to_i

    if vote.save
      redirect_back fallback_location: root_path, notice: "Vote updated."
    else
      redirect_back fallback_location: root_path, alert: vote.errors.full_messages.to_sentence
    end
  end

  def destroy
    submission = Submission.find(params[:submission_id])
    vote = submission.votes.find_by!(user: current_user)
    vote.destroy

    redirect_back fallback_location: root_path, notice: "Vote removed."
  end
end
