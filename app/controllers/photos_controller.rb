class PhotosController < ApplicationController
  before_action :authenticate_user!

  def destroy
    attachment = ActiveStorage::Attachment.find(params[:id])

    # Ensure user owns the submission
    submission = attachment.record
    unless submission.is_a?(Submission) && submission.user_id == current_user.id
      return head :forbidden
    end

    attachment.purge
    redirect_back fallback_location: root_path, notice: "Photo removed."
  end
end
