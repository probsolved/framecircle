class AddPublicToGroups < ActiveRecord::Migration[7.1]
  def change
    add_column :groups, :public, :boolean, default: false, null: false
    add_index :groups, :public
  end
end
