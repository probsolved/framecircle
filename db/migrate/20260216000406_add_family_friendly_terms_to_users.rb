class AddFamilyFriendlyTermsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :family_friendly_terms_accepted_at, :datetime
  end
end
