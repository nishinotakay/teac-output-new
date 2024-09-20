class AddChagetypeToChargePlans < ActiveRecord::Migration[6.1]
  def change
    add_column :charge_plans, :charge_type, :string
  end
end
