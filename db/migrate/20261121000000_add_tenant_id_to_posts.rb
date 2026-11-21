class AddTenantIdToPosts < ActiveRecord::Migration[6.1]
  def up
    add_column :posts, :tenant_id, :bigint

    execute <<~SQL.squish
      UPDATE posts
      LEFT JOIN users ON users.id = posts.user_id
      LEFT JOIN admins ON admins.id = posts.admin_id
      SET posts.tenant_id = COALESCE(users.tenant_id, admins.tenant_id)
    SQL

    orphan_count = select_value('SELECT COUNT(*) FROM posts WHERE tenant_id IS NULL').to_i
    if orphan_count.positive?
      # DDL は暗黙コミットされるので、列を戻して再実行できる状態で止める
      remove_column :posts, :tenant_id
      raise "tenant を決められない posts が #{orphan_count} 件あります（user_id・admin_id が無い行）"
    end

    change_column_null :posts, :tenant_id, false
    add_index :posts, :tenant_id
    add_foreign_key :posts, :tenants
  end

  def down
    remove_foreign_key :posts, :tenants
    remove_index :posts, :tenant_id
    remove_column :posts, :tenant_id
  end
end
