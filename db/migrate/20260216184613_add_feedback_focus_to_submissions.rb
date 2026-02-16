class AddFeedbackFocusToSubmissions < ActiveRecord::Migration[7.1]
  def change
    add_column :submissions, :feedback_focus, :string, array: true, default: [], null: false
  end
end
