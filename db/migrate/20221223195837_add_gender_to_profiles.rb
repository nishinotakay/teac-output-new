class AddGenderToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :gender, :integer
  end
end
