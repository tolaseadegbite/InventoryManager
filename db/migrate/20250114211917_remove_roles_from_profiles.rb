class RemoveRolesFromProfiles < ActiveRecord::Migration[8.0]
  def change
    remove_column :profiles, :role, :integer
  end
end
