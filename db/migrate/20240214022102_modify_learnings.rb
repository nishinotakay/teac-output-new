class ModifyLearnings < ActiveRecord::Migration[6.1]
  def change
    change_table :learnings do |t|
      t.remove_references :user, index: true, foreign_key: true
      t.remove_references :article, index: true, foreign_key: true
      t.integer :learner_id, null: false
      t.integer :learned_article_id, null: false
    end
  end
end
