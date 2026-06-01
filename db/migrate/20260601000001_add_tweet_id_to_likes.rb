class AddTweetIdToLikes < ActiveRecord::Migration[6.1]
  def change
    add_column :likes, :tweet_id, :bigint
    add_index :likes, :tweet_id
    add_foreign_key :likes, :tweets
  end
end
