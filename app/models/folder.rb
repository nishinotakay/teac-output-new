class Folder < ApplicationRecord
  has_many :article_folders, dependent: :destroy
  has_many :articles, through: :article_folders

  validates :name, presence: true
end

