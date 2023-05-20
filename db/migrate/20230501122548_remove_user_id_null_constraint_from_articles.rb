class RemoveUserIdNullConstraintFromArticles < ActiveRecord::Migration[6.1]
  def change
    change_column_null :articles, :user_id, true
  end
end
