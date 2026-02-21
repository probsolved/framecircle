class CommentKudosController < ApplicationController
  before_action :authenticate_user!

  def create
    comment = Comment.find(params[:comment_id])
    kind = params[:kind].to_s

    unless CommentKudo::KINDS.include?(kind)
      return redirect_back fallback_location: root_path, alert: "Invalid kudo type."
    end

    CommentKudo.find_or_create_by!(comment: comment, user: current_user, kind: kind)

    redirect_back fallback_location: group_path(comment.submission.week.group), notice: "Kudo added."

    Notification.create!(
  recipient: comment.user,          # the person who wrote the critique
  actor: current_user,              # the person giving the kudo
  group: comment.submission.week.group,
  week: comment.submission.week,
  submission: comment.submission,
  comment: comment,
  kind: "new_kudo"
)
  end

  def destroy
    comment = Comment.find(params[:comment_id])
    kind = params[:kind].to_s

    kudo = CommentKudo.find_by(comment: comment, user: current_user, kind: kind)
    kudo&.destroy

    redirect_back fallback_location: group_path(comment.submission.week.group), notice: "Kudo removed."
  end
end
