class ChangeColumnNullToProfile < ActiveRecord::Migration[6.1]
  def change
    change_column_null :profiles, :registration_date, false
    change_column_null :profiles, :hobby, false
  end
end
