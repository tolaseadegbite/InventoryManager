class AddLowStockToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :low_stock, :boolean, default: false, null: false
    add_index :items, :low_stock
  end
end
