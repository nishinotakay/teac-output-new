class CreateLearnings < ActiveRecord::Migration[6.1]
  def change
    create_table :learnings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
