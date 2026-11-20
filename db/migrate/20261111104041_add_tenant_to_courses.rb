class AddTenantToCourses < ActiveRecord::Migration[6.1]
  def change
    add_reference :courses, :tenant, null: true, foreign_key: true
  end
end
