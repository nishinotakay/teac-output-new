class AddTweetIdToLikes < ActiveRecord::Migration[6.1]
  def change
    add_column :likes, :tweet_id, :bigint
    change_column_null :likes, :article_id, true
    change_column_null :likes, :post_id, true
  end
end