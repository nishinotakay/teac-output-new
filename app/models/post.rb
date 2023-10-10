class Post < ApplicationRecord
  belongs_to :admin, optional: true
  belongs_to :user, optional: true

  validates :user_id, presence: true, if: -> { admin_id.blank? }
  validates :admin_id, presence: true, if: -> { user_id.blank? }
  validates :title, presence: true, length: { maximum: 30 }
  validates :body, presence: true, length: { maximum: 240 }
  validates :youtube_url, presence: true

  def self.sort_filter(filter)
    result = all
    result = result.joins(:user).where('name LIKE ?', "%#{filter[:author]}%") if filter[:author].present?
    result = result.where('title LIKE ?', "%#{filter[:title]}%") if filter[:title].present?
    result = result.where('body LIKE ?', "%#{filter[:body]}%") if filter[:body].present?
    result = result.where(created_at: filter[:start]..filter[:finish]) if filter[:start].present? && filter[:finish].present?
    result.order(created_at: filter[:order])
  end
end
