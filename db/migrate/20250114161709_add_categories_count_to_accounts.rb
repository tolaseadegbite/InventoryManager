class AddCategoriesCountToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :categories_count, :integer, default: 0
  end
end
