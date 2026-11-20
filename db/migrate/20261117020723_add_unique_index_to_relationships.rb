class AddUniqueIndexToRelationships < ActiveRecord::Migration[6.1]
  def up
    # ユニーク index を足す前に、同じ組み合わせの重複を最も古い 1 行だけ残して消す
    execute <<~SQL.squish
      DELETE newer FROM relationships newer
      INNER JOIN relationships older
        ON newer.follower_id = older.follower_id
       AND newer.followed_id = older.followed_id
       AND newer.id > older.id
    SQL
    add_index :relationships, %i[follower_id followed_id], unique: true
    add_index :relationships, :followed_id
  end

  # 消した重複行は戻さない（同じ関係が 1 行残っているため画面の結果は変わらない）
  def down
    remove_index :relationships, :followed_id
    remove_index :relationships, %i[follower_id followed_id]
  end
end
