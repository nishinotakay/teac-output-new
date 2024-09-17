class AddCompletedToLearnings < ActiveRecord::Migration[6.1]
  def change
    add_column :learnings, :completed, :boolean, default: false
  end
end
