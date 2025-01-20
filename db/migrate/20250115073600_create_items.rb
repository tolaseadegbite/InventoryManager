class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.text :description
      t.integer :quantity, null: false
      t.references :category, null: true, foreign_key: true
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
