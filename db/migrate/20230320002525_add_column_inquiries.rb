class AddColumnInquiries < ActiveRecord::Migration[6.1]
  def change
    add_column :inquiries, :hidden, :boolean, default: false, null: false
  end
end
