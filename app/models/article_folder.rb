class ArticleFolder < ApplicationRecord
  belongs_to :article
  belongs_to :folder
end
