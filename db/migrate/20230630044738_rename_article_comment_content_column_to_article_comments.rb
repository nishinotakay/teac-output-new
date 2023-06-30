class RenameArticleCommentContentColumnToArticleComments < ActiveRecord::Migration[6.1]
  def change
    rename_column :article_comments, :article_comment_content, :content
    rename_column :article_comments, :article_confirmed, :confirmed
  end
end
