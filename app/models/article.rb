# frozen_string_literal: true

class Article < ApplicationRecord
  mount_uploader :image, ImageUploader # ようせい追加（画像保存）

  belongs_to :user
  validates :title, presence: true, length: { in: 1..20 }
  validates :sub_title, allow_nil: true, length: { in: 1..40 }
  validates :content, presence: true

  def self.time_filter(start, finish)
    start = start.to_datetime.ago(9.hours)
    finish = finish.to_datetime.end_of_day.ago(9.hours)
    articles = where("created_at between ? and ?", start, finish).presence
    return articles.blank? ? [] : articles
  end

  def self.multi_filter(filter)
    articles = joins(:user).merge(where('name like ?', "%#{filter[:author]}%"))
      .where(["title like ? and sub_title like ?", "%#{filter[:title]}%", "%#{filter[:subtitle]}%"]).presence
    return articles.blank? ? [] : articles
  end
end
