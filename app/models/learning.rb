class Learning < ApplicationRecord
  belongs_to :learner, class_name: "User", optional: true
  belongs_to :admin, class_name: "Admin", optional: true
  belongs_to :learned_article, class_name: "Article"
end
