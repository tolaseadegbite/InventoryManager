class CreateCategoryPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :category_permissions do |t|
      t.references :inventory_user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
      
      t.index [:inventory_user_id, :category_id], unique: true, 
              name: 'index_category_permissions_on_inventory_user_and_category'
    end
  end
end
