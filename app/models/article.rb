# frozen_string_literal: true

class Article < ApplicationRecord
  mount_uploader :image, ImageUploader # ようせい追加（画像保存）
  validates :user_id, presence: true, if: -> { admin_id.blank? }
  validates :admin_id, presence: true, if: -> { user_id.blank? }

  belongs_to :admin, optional: true
  belongs_to :user, optional: true
  has_many :article_comments, dependent: :destroy

  validates :title, presence: true, length: { in: 1..40 }
  validates :sub_title, allow_nil: true, length: { maximum: 50 }
  validates :content, presence: true

  def self.sort_filter(filter)
    start = Time.zone.parse(filter[:start].presence || '2022-01-01').beginning_of_day
    finish = Time.zone.parse(filter[:finish].presence || Date.current.to_s).end_of_day

    articles = left_joins(:user, :admin)
              .where(['title LIKE ? AND sub_title LIKE ? AND content LIKE ?',
              "%#{filter[:title]}%", "%#{filter[:subtitle]}%", "%#{filter[:content]}%"])
              .where('articles.created_at BETWEEN ? AND ?', start, finish)
              .where('users.name LIKE :author OR admins.name LIKE :author', author: "%#{filter[:author]}%")
              .order("articles.created_at #{filter[:order]}")
    articles.presence || []
  end
end
