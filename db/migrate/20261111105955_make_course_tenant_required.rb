class MakeCourseTenantRequired < ActiveRecord::Migration[6.1]
  def change
    change_column_null :courses, :tenant_id, false
  end
end
