class ChargePlan < ApplicationRecord
  validates :price, numericality: { greater_than: 0,}
  validates :quantity, numericality: { greater_than: 0,}
  validates :amount, presence: true
  validates :charge_type, presence: true

  belongs_to :admin

  def amount_calc(price, quantity)
    price * quantity
  end

end
