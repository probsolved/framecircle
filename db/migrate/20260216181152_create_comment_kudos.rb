class CreateCommentKudos < ActiveRecord::Migration[7.1]
  def change
    create_table :comment_kudos do |t|
      t.references :comment, null: false, foreign_key: { on_delete: :cascade }
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :kind, null: false

      t.timestamps
    end

    add_index :comment_kudos, [ :comment_id, :user_id, :kind ], unique: true
    add_index :comment_kudos, [ :comment_id, :kind ]
  end
end
