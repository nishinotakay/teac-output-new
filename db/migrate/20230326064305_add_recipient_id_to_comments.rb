class AddRecipientIdToComments < ActiveRecord::Migration[6.1]
  def change
    add_column :comments, :recipient_id, :integer, null: false
  end
end
