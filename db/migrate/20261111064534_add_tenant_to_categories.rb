class AddTenantToCategories < ActiveRecord::Migration[6.1]
  def change
    add_reference :categories, :tenant, null: true, foreign_key: true
  end
end
