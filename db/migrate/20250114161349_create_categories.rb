class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.text :description
      t.references :inventory, null: false, foreign_key: true
      t.integer :items_count, default: 0

      t.timestamps
    end
  end
end
