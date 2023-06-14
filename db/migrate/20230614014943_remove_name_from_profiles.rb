class RemoveNameFromProfiles < ActiveRecord::Migration[6.1]
  def change
    remove_column :profiles, :name, :string
  end
end
