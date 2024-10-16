# frozen_string_literal: true

class Article < ApplicationRecord
  mount_uploader :image, ImageUploader # ようせい追加（画像保存）
  after_create :assign_to_default_folder
  
  validates :user_id, presence: true, if: -> { admin_id.blank? }
  validates :admin_id, presence: true, if: -> { user_id.blank? }

  belongs_to :admin, optional: true
  belongs_to :user, optional: true
  has_many :article_comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :stocks, dependent: :destroy

  has_many :learnings
  has_many :users, through: :learnings

  has_many :article_folders, dependent: :destroy
  has_many :folders, through: :article_folders

  validates :title, presence: true, length: { in: 1..40 }
  validates :sub_title, allow_nil: true, length: { maximum: 50 }
  validates :content, presence: true
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

  def self.stock_paginated_and_sort_filter(filter,user)
    
    start = Time.zone.parse(filter[:start].presence || '2020-01-01').beginning_of_day
    finish = Time.zone.parse(filter[:finish].presence || Date.current.to_s).end_of_day
    
    left_joins(:user, :admin, :stocks)
      .includes(:admin, :user, :article_comments)
      .where(['title LIKE ? AND sub_title LIKE ? AND content LIKE ?',
              "%#{filter[:title]}%", "%#{filter[:subtitle]}%", "%#{filter[:content]}%"])
      .where('articles.created_at BETWEEN ? AND ?', start, finish)
      .where('users.name LIKE :author OR admins.name LIKE :author', author: "%#{filter[:author]}%")
      .where('stocks.user_id = ?', user.id)
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
      admin_id.present?
    end

    def assign_to_default_folder
      return unless user.present?
      uncategorized_folder = user.folders.find_by(name: '未分類')
      if uncategorized_folder
        ArticleFolder.create!(article_id: self.id, folder_id: uncategorized_folder.id)
      end
    end
end

