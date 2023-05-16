class Post < ApplicationRecord
  belongs_to :user

  validates :title, presence: true, length: { maximum: 30 }
  validates :body, presence: true, length: { maximum: 240 }
  validates :youtube_url, presence: true
  def self.search(search) # self.はcurrent_user.posts.を意味する
    if search
      where(['body LIKE ? OR title LIKE ?', "%#{search}%", "%#{search}%"]) # 検索とtitleとbodyの部分一致を表示。
    else
      all # 全て表示させる
    end
  end

  # 絞り込み検索(モーダル)
  def self.sort_filter(filter)
    result = all
    result = result.joins(:user).where('name LIKE ?', "%#{filter[:author]}%") if filter[:author].present?
    result = result.where('title LIKE ?', "%#{filter[:title]}%") if filter[:title].present?
    result = result.where('body LIKE ?', "%#{filter[:body]}%") if filter[:body].present?
    result = result.where(created_at: filter[:start]..filter[:finish]) if filter[:start].present? && filter[:finish].present?
    result.order(created_at: filter[:order])
  end  
end
