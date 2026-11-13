class AddUniqueIndexToFoldersOnUserIdAndName < ActiveRecord::Migration[6.1]
  def change
    add_index :folders, [:user_id, :name], unique: true
  end
end
