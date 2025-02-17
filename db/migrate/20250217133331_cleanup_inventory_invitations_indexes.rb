class CleanupInventoryInvitationsIndexes < ActiveRecord::Migration[8.0]
  def change
    # Remove duplicate composite index
    remove_index :inventory_invitations, name: "index_inventory_invitations_on_recipient_id_and_inventory_id"
    
    # Remove redundant single column indexes since they're covered by the composite index
    remove_index :inventory_invitations, name: "index_inventory_invitations_on_inventory_id"
    remove_index :inventory_invitations, name: "index_inventory_invitations_on_recipient_id"
    
    # Keep these indexes:
    # - inventory_id, recipient_id (composite)
    # - sender_id
  end
end