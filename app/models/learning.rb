class Learning < ApplicationRecord
  belongs_to :learner, class_name: "User"
  belongs_to :learned_article, class_name: "Article"
end
