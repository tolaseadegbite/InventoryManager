class AddStockThresholdToItems < ActiveRecord::Migration[8.0]
  def change
    add_column :items, :stock_threshold, :integer, default: 0
    add_column :accounts, :global_stock_threshold, :integer, default: 0
  end
end
