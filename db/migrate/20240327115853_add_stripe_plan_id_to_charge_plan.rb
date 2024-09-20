class AddStripePlanIdToChargePlan < ActiveRecord::Migration[6.1]
  def change
    add_column :charge_plans, :stripe_plan_id, :string
    add_column :charge_plans, :stripe_subscription_id, :string
  end
end
