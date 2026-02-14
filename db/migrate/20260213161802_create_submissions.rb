class CreateSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :submissions do |t|
      t.references :week, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :caption
      t.datetime :locked_at

      t.timestamps
    end
  end
end
