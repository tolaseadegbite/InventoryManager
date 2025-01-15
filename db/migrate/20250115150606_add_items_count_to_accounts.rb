class AddItemsCountToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :items_count, :integer, default: 0, null: false
  end
end
