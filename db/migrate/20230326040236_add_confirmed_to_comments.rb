class AddConfirmedToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :confirmed, :boolean, default: false
  end
end
