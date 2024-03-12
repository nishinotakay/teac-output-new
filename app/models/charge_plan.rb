class ChargePlan < ApplicationRecord
  validates :price, numericality: { greater_than: 0,}
  validates :quantity, numericality: { greater_than: 0,}
  validates :amount, numericality: { greater_than: 0,}
  validates :charge_type, presence: true
end
