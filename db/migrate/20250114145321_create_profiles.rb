class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :role, default: 0, null: false

      t.timestamps
    end
  end
end
