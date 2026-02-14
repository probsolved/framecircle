class AddUniqueWeekRangePerGroup < ActiveRecord::Migration[8.0]
  def change
    add_index :weeks, [ :group_id, :starts_on, :ends_on ], unique: true
  end
end
