class RemoveComentFromTweets < ActiveRecord::Migration[6.1]
  def change
    remove_column :tweets, :coment, :string
    remove_column :tweets, :good, :string
  end
end
