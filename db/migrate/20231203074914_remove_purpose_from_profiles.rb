class RemovePurposeFromProfiles < ActiveRecord::Migration[6.1]
  def change
    remove_column :profiles, :purpose, :string
  end
end
