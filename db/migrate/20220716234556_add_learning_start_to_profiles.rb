class AddLearningStartToProfiles < ActiveRecord::Migration[6.1]
  def change
    add_column :profiles, :learning_start, :date
  end
end
