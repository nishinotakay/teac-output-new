class Folder < ApplicationRecord
  DEFAULT_NAME = '未分類'.freeze
  NAME_MAX_LENGTH = 30

  has_many :article_folders, dependent: :destroy
  has_many :articles, through: :article_folders

  validates :name, presence: true, length: { maximum: NAME_MAX_LENGTH }, uniqueness: { scope: :user_id }

  def default?
    name == DEFAULT_NAME
  end

  # 中の記事を移動先へ付け替えてから消す（記事そのものは消さない）
  def destroy_moving_articles_to!(destination_folder)
    transaction do
      article_folders.update_all(folder_id: destination_folder.id, updated_at: Time.current)
      destroy!
    end
  end
end

