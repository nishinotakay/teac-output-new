class ChargePlan < ApplicationRecord
  validates :price, presence: true, numericality: { greater_than: 0,}, if: :not_free_plan
  validates :quantity, presence: true, numericality: { greater_than: 0,}, if: :not_free_plan
  validates :amount, presence: true
  validates :charge_type, presence: true
  validate :check_double_charge, on: :create

  belongs_to :admin

  def amount_calc(price, quantity)
    price * quantity
  end

  private

  def not_free_plan
    charge_type == "定額決済" || charge_type == "一括決済"
  end

  def check_double_charge 
    charge_plan = ChargePlan.find_by(admin_id: self.admin_id)
    if charge_plan.present?
      errors.add(:deadline, "すでに受講料金が設定されています。")
    end
  end

end
