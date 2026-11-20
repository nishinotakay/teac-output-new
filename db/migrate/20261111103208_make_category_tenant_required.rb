class MakeCategoryTenantRequired < ActiveRecord::Migration[6.1]
  def change
    change_column_null :categories, :tenant_id, false
  end
end
