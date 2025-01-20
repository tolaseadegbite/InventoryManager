class ChangeItemsColumnNullToFalse < ActiveRecord::Migration[8.0]
  def change
    change_column_null :items, :quantity, false
  end
end
