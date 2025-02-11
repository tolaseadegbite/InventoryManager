class CreateInventoryActions < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_actions do |t|
      t.references :inventory, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :action_type, null: false  # 'add' or 'remove'
      t.integer :quantity, null: false
      t.text :notes
      
      t.timestamps
    end

    add_index "inventory_actions", ["inventory_id", "item_id"], name: "index_inventory_actions_on_inventory_and_item"
  end
end
