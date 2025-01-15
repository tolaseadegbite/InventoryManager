class AddInventoryActionsCountToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :inventory_actions_count, :integer, default: 0, null: false
    add_column :accounts, :inventory_actions_count, :integer, default: 0, null: false
  end
end
