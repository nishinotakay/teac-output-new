class ChangeCommentContentToContentInTweetComments < ActiveRecord::Migration[6.1]
  def change
    rename_column :tweet_comments, :comment_content, :content
  end
end
