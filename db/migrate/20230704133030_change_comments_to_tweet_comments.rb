class ChangeCommentsToTweetComments < ActiveRecord::Migration[6.1]
  def change
    rename_table :tweetComments, :tweet_comments
  end
end
