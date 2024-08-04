class AddUserAndAdminToFolders < ActiveRecord::Migration[6.1]
  def change
    add_reference :folders, :user, foreign_key: true, index: true
    add_reference :folders, :admin, foreign_key: true, index: true
  end
end
