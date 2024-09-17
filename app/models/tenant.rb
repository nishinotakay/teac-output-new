class Tenant < ApplicationRecord
  validates :name, presence: true, length: { in: 1..20 }
end
