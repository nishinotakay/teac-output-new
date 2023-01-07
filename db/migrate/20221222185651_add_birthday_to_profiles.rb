class AddBirthdayToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :birthday, :date
  end
end
