class ChangePostToBeNotNullInTweets < ActiveRecord::Migration[6.1]
  def change
    change_column_null :tweets, :post, false
  end
end
