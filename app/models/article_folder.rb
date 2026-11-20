class ArticleFolder < ApplicationRecord
  belongs_to :article
  belongs_to :folder
  validates :article_id, uniqueness: true
end

