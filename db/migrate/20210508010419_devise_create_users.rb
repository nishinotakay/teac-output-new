# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      ## Database authenticatable 
      # サインイン時にユーザーの正当性を検証するためにパスワードを暗号化してDBに登録します。
      # 認証方法としてはPOSTリクエストかHTTP Basic認証が使えます。
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      # パスワードをリセットし、それを通知します。
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      # 保存されたcookieから、ユーザーを記憶するためのトークンを生成・削除します。
      t.datetime :remember_created_at

      ## Trackable
      # サインイン回数や、サインイン時間、IPアドレスを記録します。
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      # メールに記載されているURLをクリックして本登録を完了する、といったよくある登録方式を提供します。
      # また、サインイン中にアカウントが認証済みかどうかを検証します。
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # 一定回数サインインを失敗するとアカウントをロックします。
      # ロック解除にはメールによる解除か、一定時間経つと解除するといった方法があります。
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true
  end
end
