class AddTenantIdToAdmins < ActiveRecord::Migration[6.1]
  def change
    add_column :admins, :tenant_id, :bigint
  end
end
