class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.text :description
      t.integer :quantity, null: false
      t.integer :stock_threshold, default: 0, null: false
      t.boolean :low_stock, default: false, null: false
      t.integer :inventory_actions_count, default: 0, null: false
      t.references :category, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
