class Profile < ApplicationRecord
  has_one_attached :image
  belongs_to :user
  accepts_nested_attributes_for :user
  
  validates :learning_start, presence: true
  validates :purpose, presence: true
  
  enum gender: { male: 0, female: 1, other: 2 }
end
