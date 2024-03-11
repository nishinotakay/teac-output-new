class ChargePlan < ApplicationRecord
  validates :price, presence: true
  validates :quantity, presence: true
  validates :charge_type, presence: true
end
