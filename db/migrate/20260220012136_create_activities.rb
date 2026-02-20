# db/migrate/xxxxxx_create_activities.rb
class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :group, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: { to_table: :users }

      t.string :action, null: false

      t.references :subject, polymorphic: true, null: false
      t.references :target, polymorphic: true

      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :activities, [ :group_id, :occurred_at ]
    add_index :activities, [ :action, :occurred_at ]
  end
end
