class ArticleComment < ApplicationRecord
  belongs_to :user
  belongs_to :article

  validates :article_comment_content, presence: true
end
