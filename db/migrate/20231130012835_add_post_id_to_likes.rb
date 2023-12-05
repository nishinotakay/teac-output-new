class AddPostIdToLikes < ActiveRecord::Migration[6.1]
  def change
    add_column :likes, :post_id, :bigint
    change_column_null :likes, :article_id, true
  end
end
