class CreateInventoryUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :inventory_users do |t|
      t.references :inventory, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 3

      t.timestamps

      t.index [:inventory_id, :user_id], unique: true
    end
  end
end
