class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.integer :status, default: 0, null: false
      t.integer :categories_count, default: 0
      t.integer :role, default: 0, null: false
      t.integer :items_count, default: 0, null: false
      t.integer :inventory_actions_count, default: 0, null: false
      t.integer :global_stock_threshold, default: 0, null: false


      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end
