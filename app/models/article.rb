# frozen_string_literal: true

class Article < ApplicationRecord
  mount_uploader :image, ImageUploader # ようせい追加（画像保存）
  validates :user_id, presence: true, if: -> { admin_id.blank? }
  validates :admin_id, presence: true, if: -> { user_id.blank? }

  belongs_to :admin, optional: true
  belongs_to :user, optional: true
  has_many :article_comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  validates :title, presence: true, length: { in: 1..40 }
  validates :sub_title, allow_nil: true, length: { maximum: 50 }
  validates :content, presence: true
  # バリデーション: adminが記事をupdateするときにarticle_typeの値が必須、userがupdateするときはnilでもOK
  # また、create時にも適用する
  validates :article_type, presence: true, if: :admin_updating_or_creating?

  def self.paginated_and_sort_filter(filter)
    
    start = Time.zone.parse(filter[:start].presence || '2020-01-01').beginning_of_day
    finish = Time.zone.parse(filter[:finish].presence || Date.current.to_s).end_of_day
    
    left_joins(:user, :admin)
      .includes(:admin, :user, :article_comments)
      .where(['title LIKE ? AND sub_title LIKE ? AND content LIKE ? AND (articles.article_type != ? OR articles.article_type IS NULL)',
              "%#{filter[:title]}%", "%#{filter[:subtitle]}%", "%#{filter[:content]}%", 'e-learning'])
      .where('articles.created_at BETWEEN ? AND ?', start, finish)
      .where('users.name LIKE :author OR admins.name LIKE :author', author: "%#{filter[:author]}%")
      .order(created_at: "#{filter[:order]}")
      .page(filter[:page]).per(30)
      .presence || Article.none
  end

  # scriptタグとiframeタグを取り除くメソッド
  def sanitized_content
    self.content.gsub(/<script>.*<\/script>/m, '').gsub(/<iframe[\s\S]*?<\/iframe>/m, '')
  end

  private

    def admin_updating_or_creating?
      # idが存在すれば更新、存在しなければ新規作成
      id.present? || admin_id.present?
    end
end
