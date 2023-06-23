class RemoveAdminIdNullConstraintFromArticles < ActiveRecord::Migration[6.1]
  def change
    change_column_null :articles, :admin_id, true
  end
end
