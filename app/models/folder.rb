class Folder < ApplicationRecord
  has_many :article_folders
  has_many :articles, through: :article_folders

  validates :name, presence: true
end
