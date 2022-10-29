class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 30 }
  validates :body, presence: true, length: { maximum: 240 }
  validates :youtube_url, presence: true
  def self.search(search) #self.はcurrent_user.posts.を意味する
    if search
      where(['body LIKE ? OR title LIKE ?', "%#{search}%", "%#{search}%"]) #検索とtitleとbodyの部分一致を表示。
    else
      all #全て表示させる
    end
  end
end