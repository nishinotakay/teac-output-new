class AddTenantIdToChatRooms < ActiveRecord::Migration[6.1]
  def up
    rooms_without_users = select_value(<<~SQL.squish)
      SELECT COUNT(*) FROM chat_rooms
      WHERE NOT EXISTS (
        SELECT 1 FROM chat_room_users WHERE chat_room_users.chat_room_id = chat_rooms.id
      )
    SQL

    rooms_with_mixed_tenants = select_value(<<~SQL.squish)
      SELECT COUNT(*) FROM (
        SELECT chat_room_users.chat_room_id
        FROM chat_room_users
        JOIN users ON users.id = chat_room_users.user_id
        GROUP BY chat_room_users.chat_room_id
        HAVING COUNT(DISTINCT users.tenant_id) > 1
      ) AS mixed_rooms
    SQL

    if rooms_without_users.to_i.positive? || rooms_with_mixed_tenants.to_i.positive?
      raise "テナントを決められない部屋があります（参加者なし: #{rooms_without_users} 件、テナント混在: #{rooms_with_mixed_tenants} 件）"
    end

    add_column :chat_rooms, :tenant_id, :bigint

    execute <<~SQL.squish
      UPDATE chat_rooms
      JOIN chat_room_users ON chat_room_users.chat_room_id = chat_rooms.id
      JOIN users ON users.id = chat_room_users.user_id
      SET chat_rooms.tenant_id = users.tenant_id
    SQL

    change_column_null :chat_rooms, :tenant_id, false
    add_index :chat_rooms, :tenant_id
    add_foreign_key :chat_rooms, :tenants
  end

  def down
    remove_foreign_key :chat_rooms, :tenants
    remove_index :chat_rooms, :tenant_id
    remove_column :chat_rooms, :tenant_id
  end
end
