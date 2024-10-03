class AddAdminIdToLearnings < ActiveRecord::Migration[6.1]
  def change
    add_column :learnings, :admin_id, :integer
    add_index :learnings, :admin_id
  end
end
