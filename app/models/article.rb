# frozen_string_literal: true

class Article < ApplicationRecord
  mount_uploader :image, ImageUploader # ようせい追加（画像保存）

  belongs_to :user
  validates :title, presence: true, length: { in: 1..40 }
  validates :sub_title, allow_nil: true, length: { maximum: 50 }
  validates :content, presence: true

  def self.sort_filter(filter)
    start = filter[:start].blank? ? '2022-01-01' : filter[:start]
    finish = filter[:finish].blank? ? Date.current : filter[:finish]
    start = start.to_datetime.since(9.hours).beginning_of_day
    finish = finish.to_datetime.since(9.hours).end_of_day
    articles = order("articles.created_at #{filter[:order]}")
      .where(['title like ? and sub_title like ? and content like ?',
              "%#{filter[:title]}%", "%#{filter[:subtitle]}%", "%#{filter[:content]}%"])
      .where('articles.created_at between ? and ?', start, finish)
      .joins(:user).merge(where('name like ?', "%#{filter[:author]}%")).presence
    articles.blank? ? [] : articles
  end
end
