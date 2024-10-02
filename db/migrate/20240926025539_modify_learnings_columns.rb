class ModifyLearningsColumns < ActiveRecord::Migration[6.1]
  def change
    change_column_null :learnings, :learner_id, true
  end
end
