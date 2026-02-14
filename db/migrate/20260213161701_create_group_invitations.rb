class CreateGroupInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :group_invitations do |t|
      t.references :group, null: false, foreign_key: true
      t.string :email
      t.string :token
      t.bigint :invited_by_id
      t.datetime :accepted_at

      t.timestamps
    end
  end
end
