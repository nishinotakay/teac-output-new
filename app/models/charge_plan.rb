class ChargePlan < ApplicationRecord
  validates :price, numericality: { greater_than: 0,}, if: :not_free_plan
  validates :quantity, numericality: { greater_than: 0,}, if: :not_free_plan
  validates :amount, presence: true
  validates :charge_type, presence: true

  belongs_to :admin

  def amount_calc(price, quantity)
    price * quantity
  end

  private

    def not_free_plan
      return true if charge_type == "定額決済" || charge_type === "一括決済"
      false
    end

end
