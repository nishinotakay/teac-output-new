class AddOauthToUser < ActiveRecord::Migration[6.1]
  def change
    unless ActiveRecord::Base.connection.column_exists?(:users, :uid)
      add_column :users, :uid, :string
    end

    unless ActiveRecord::Base.connection.column_exists?(:users, :provider)
      add_column :users, :provider, :string
    end
  end
end
