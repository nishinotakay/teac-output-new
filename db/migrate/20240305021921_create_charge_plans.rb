class CreateChargePlans < ActiveRecord::Migration[6.1]
  def change
    create_table :charge_plans do |t|
      t.boolean :charge, null: false, default: false
      t.boolean :subscription, null: false, default: false
      t.boolean :free, null: false, default: false
      t.integer :price, null: false, default: 0
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
