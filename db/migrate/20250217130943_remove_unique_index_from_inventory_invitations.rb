class RemoveUniqueIndexFromInventoryInvitations < ActiveRecord::Migration[8.0]
  def change
    # Remove the unique index
    remove_index :inventory_invitations, name: "index_inventory_invitations_on_inventory_id_and_recipient_id"
    
    # Add back a non-unique index for query performance
    add_index :inventory_invitations, [:inventory_id, :recipient_id], name: "index_inventory_invitations_on_inventory_id_and_recipient_id"
  end
end