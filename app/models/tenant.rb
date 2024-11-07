class Tenant < ApplicationRecord
  has_many :users
  validates :name, presence: true, length: { in: 1..20 }
end
