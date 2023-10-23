class RemoveAdminIdFromPosts < ActiveRecord::Migration[6.1]
  def change
    remove_column :posts, :admin_id, :integer
  end
end
