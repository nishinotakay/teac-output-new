# frozen_string_literal: true

require 'apartment/elevators/generic'

# Apartmentの設定
# 'ros-apartment' を使用している場合、設定が異なることがあります。
Apartment::Tenant.init do |config|
  # マルチテナント化しないモデルを指定します。
  config.excluded_models = %w{ Tenant }

  # テナントの名前を定義します。テナントごとに異なるデータベースまたはスキーマに対応します。
  config.tenant_names = -> { Tenant.pluck(:name) }

  # MySQLまたはPostgreSQLでスキーマを使用するかどうか
  config.use_schemas = true
end

# Custom Elevatorを使用して、ルーティングに基づいたテナント切り替えを行います。
Rails.application.config.middleware.use Apartment::Elevators::Generic, lambda { |request|
  request.params['tenant_id']
}
