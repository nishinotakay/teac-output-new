class AddTenantIdToCourses < ActiveRecord::Migration[6.1]
  def up
    course_count = select_value('SELECT COUNT(*) FROM courses').to_i
    tenant_ids = select_values('SELECT id FROM tenants')

    if course_count.positive? && tenant_ids.size != 1
      raise 'コースが存在するがテナントが 1 件ではないため、割り当て先を決められません'
    end

    add_column :courses, :tenant_id, :bigint
    execute "UPDATE courses SET tenant_id = #{tenant_ids.first.to_i}" if course_count.positive?

    change_column_null :courses, :tenant_id, false
    add_index :courses, :tenant_id
    add_foreign_key :courses, :tenants
  end

  def down
    remove_foreign_key :courses, :tenants
    remove_index :courses, :tenant_id
    remove_column :courses, :tenant_id
  end
end
