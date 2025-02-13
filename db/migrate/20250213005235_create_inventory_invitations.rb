class CreateInventoryInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_invitations do |t|
      t.references :inventory, null: false, foreign_key: true
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.integer :role, null: false, default: 2  # default to viewer
      t.integer :status, null: false, default: 0  # default to pending
      
      t.timestamps
      
      t.index [:inventory_id, :recipient_id], unique: true
    end
  end
end
