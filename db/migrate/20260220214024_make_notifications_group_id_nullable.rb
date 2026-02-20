class MakeNotificationsGroupIdNullable < ActiveRecord::Migration[7.1]
  def change
    change_column_null :notifications, :group_id, true
  end
end
