class RelaxNotificationNullConstraints < ActiveRecord::Migration[7.1]
  def change
    change_column_null :notifications, :week_id, true
    change_column_null :notifications, :submission_id, true

    # If these columns exist and you use them conditionally, include them too:
    change_column_null :notifications, :comment_id, true if column_exists?(:notifications, :comment_id)
    change_column_null :notifications, :group_id, true if column_exists?(:notifications, :group_id)

    # Optional but recommended: make kind required if it isn't already
    change_column_null :notifications, :kind, false if column_exists?(:notifications, :kind)
  end
end
