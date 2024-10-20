# frozen_string_literal: true
require 'apartment'
require 'apartment/elevators/generic'

# Apartmentの設定
Apartment.configure do |config|
  # マルチテナント化しないモデルを指定します。
  config.excluded_models = %w{ Tenant }

  # テナントの名前を定義します。テナントごとに異なるデータベースまたはスキーマに対応します。
  config.tenant_names = -> {
    tenant_names = Tenant.pluck(:name)  # 変数名を tenant_names に変更
    puts "Migrating tenants: #{tenant_names}"  # tenant_names を出力
    tenant_names  # tenant_names を返す
  }

  # MySQLまたはPostgreSQLでスキーマを使用するかどうか
  config.use_schemas = true
end

# Custom Elevatorを使用して、ルーティングに基づいたテナント切り替えを行います。
Rails.application.config.middleware.use Apartment::Elevators::Generic, lambda { |request|
  request.params['tenant_id']
}
