class AddTenantIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :tenant_id, :bigint
  end
end
