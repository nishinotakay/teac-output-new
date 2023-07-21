class ChangeColumnNameInTenants < ActiveRecord::Migration[6.1]
  def change
    change_column :tenants, :name, :string, null: false, limit: 20
  end
end
