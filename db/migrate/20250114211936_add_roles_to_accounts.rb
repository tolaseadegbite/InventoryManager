class AddRolesToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :role, :integer, default: 1, null: false
  end
end
