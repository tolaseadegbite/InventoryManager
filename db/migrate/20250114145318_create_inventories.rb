class CreateInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :inventories do |t|
      t.string :name, null: false
      t.text :description
      t.integer :global_stock_threshold, default: 0, null: false
      t.integer :categories_count, default: 0
      t.integer :items_count, default: 0
      t.integer :inventory_actions_count, default: 0
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
