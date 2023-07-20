class AddRegistrationDateAndHobbyToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :registration_date, :date
    add_column :profiles, :hobby, :string
  end
end
