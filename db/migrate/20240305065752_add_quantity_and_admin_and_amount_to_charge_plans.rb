class AddQuantityAndAdminAndAmountToChargePlans < ActiveRecord::Migration[6.1]
  def change
    add_column :charge_plans, :quantity, :integer, null:false , default: 0
    add_column :charge_plans, :amount, :integer, null:false, default: 0
    add_reference :charge_plans, :admin, null: false, foreign_key: true
  end
end
