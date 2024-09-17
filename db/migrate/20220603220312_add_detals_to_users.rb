class AddDetalsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :learning_history, :integer
    add_column :users, :purpose, :string
  end
end
