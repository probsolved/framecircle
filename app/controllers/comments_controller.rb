class CommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    submission = Submission.find(params[:submission_id])

    comment = submission.comments.new(comment_params)
    comment.user = current_user

    if comment.save
      redirect_back fallback_location: root_path, notice: "Critique posted."
    else
      redirect_back fallback_location: root_path, alert: comment.errors.full_messages.to_sentence
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body, :photo_index, :parent_id)
  end
end
