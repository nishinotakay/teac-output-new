class CreateProfiles < ActiveRecord::Migration[6.1]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :learning_history
      t.string :purpose

      t.timestamps
    end
  end
end
