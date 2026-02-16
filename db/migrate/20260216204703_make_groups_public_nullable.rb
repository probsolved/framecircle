class MakeGroupsPublicNullable < ActiveRecord::Migration[8.0]
  def change
    change_column_default :groups, :public, from: false, to: nil
    change_column_null :groups, :public, true
  end
end
