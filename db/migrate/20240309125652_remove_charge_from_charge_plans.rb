class RemoveChargeFromChargePlans < ActiveRecord::Migration[6.1]
  def change
    remove_column :charge_plans, :charge, :boolean
    remove_column :charge_plans, :subscription, :boolean
    remove_column :charge_plans, :free, :boolean
    remove_column :charge_plans, :user_id, :bigint
  end
end
