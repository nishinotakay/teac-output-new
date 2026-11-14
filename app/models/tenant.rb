class Tenant < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :admins, dependent: :restrict_with_error
  has_many :categories
  has_many :courses
  validates :name, presence: true, length: { in: 1..20 }
end
