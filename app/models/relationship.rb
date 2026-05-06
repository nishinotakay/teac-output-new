# フォロー関係モデル: ユーザー間のフォロー（follower → followed）の関連付けを管理する

class Relationship < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
end
