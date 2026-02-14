class AddOwnerForeignKeyToGroups < ActiveRecord::Migration[7.1]
  def change
    add_index :groups, :owner_id
    add_foreign_key :groups, :users, column: :owner_id
  end
end
