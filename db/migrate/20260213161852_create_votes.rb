class CreateVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :votes do |t|
      t.references :submission, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :photo_index

      t.timestamps
    end
  end
end
