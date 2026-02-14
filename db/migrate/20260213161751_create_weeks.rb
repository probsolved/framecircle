class CreateWeeks < ActiveRecord::Migration[8.0]
  def change
    create_table :weeks do |t|
      t.references :group, null: false, foreign_key: true
      t.string :title
      t.date :starts_on
      t.date :ends_on
      t.integer :status

      t.timestamps
    end
  end
end
