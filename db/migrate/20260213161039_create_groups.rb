class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :slug
      t.bigint :owner_id
      t.boolean :private

      t.timestamps
    end
  end
end
