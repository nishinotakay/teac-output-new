class ChangeCommentsToTweetComments < ActiveRecord::Migration[6.1]
  def change
    rename_table :comments, :tweet_comments
  end
end
