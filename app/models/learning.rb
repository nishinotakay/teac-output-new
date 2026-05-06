# 学習進捗モデル: ユーザー・管理者のe-learning記事の受講完了状況を記録する

class Learning < ApplicationRecord
  belongs_to :learner, class_name: "User", optional: true
  belongs_to :admin, class_name: "Admin", optional: true
  belongs_to :learned_article, class_name: "Article"
end
