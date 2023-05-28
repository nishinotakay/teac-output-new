# frozen_string_literal: true

class Article < ApplicationRecord
  mount_uploader :image, ImageUploader # ようせい追加（画像保存）
  validates :user_id, presence: true, if: -> { admin_id.blank? }
  validates :admin_id, presence: true, if: -> { user_id.blank? }
  
  belongs_to :admin, optional: true
  belongs_to :user, optional: true

  validates :title, presence: true, length: { in: 1..40 }
  validates :sub_title, allow_nil: true, length: { maximum: 50 }
  validates :content, presence: true

  def self.sort_filter(filter)
    start = filter[:start].blank? ? Time.zone.parse('2022-01-01') : filter[:start].to_datetime
    finish = filter[:finish].blank? ? Time.zone.now.to_date : filter[:finish].to_datetime
  
    start = start.since(9.hours).beginning_of_day
    finish = finish.since(9.hours).end_of_day
    articles = order("articles.created_at #{filter[:order]}")
      .where(['title like ? and sub_title like ? and content like ?',
              "%#{filter[:title]}%", "%#{filter[:subtitle]}%", "%#{filter[:content]}%"])
      .where('articles.created_at between ? and ?', start, finish)
      .joins(:user).merge(where('name like ?', "%#{filter[:author]}%")).presence
    articles.blank? ? [] : articles
  end
end
