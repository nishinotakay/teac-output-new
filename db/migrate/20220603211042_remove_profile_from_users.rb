class RemoveProfileFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :profile, :text
  end
end
