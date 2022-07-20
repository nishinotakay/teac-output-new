class Profile < ApplicationRecord
  has_one_attached :image
  belongs_to :user

  validates :name, presence: true, length: { in: 1..20 }
  # validates :learning_history, presence: true
  validates :purpose, presence: true
  validates :learning_start, presence: true
end
