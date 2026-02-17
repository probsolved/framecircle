class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.references :group, null: false, foreign_key: true
      t.references :week, null: false, foreign_key: true
      t.references :submission, null: false, foreign_key: true
      t.references :comment, null: false, foreign_key: true
      t.string :kind
      t.datetime :read_at

      t.timestamps
    end
  end
end
