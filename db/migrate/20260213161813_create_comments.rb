class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.references :submission, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :photo_index
      t.text :body
      t.bigint :parent_id

      t.timestamps
    end
  end
end
