# frozen_string_literal: true
require 'apartment'
require 'apartment/elevators/generic'

Apartment.configure do |config|
  # マルチテナント化しないモデルを指定
  config.excluded_models = %w{ Tenant }

  # テナントの名前を定義
  config.tenant_names = lambda do
    tenant_names = Tenant.pluck(:name)
    tenant_names
  end

  # 各テナントに対して個別のスキーマを作成
  config.use_schemas = true
end

# ルーティングもしくはセッションに保存されたtenant_idによりテナントを切り替え。
# サブドメインを使用する場合は、他のエレベーター（Subdomain Elevator）を使用してテナントを切り替えることも可能。
Rails.application.config.middleware.use Apartment::Elevators::Generic, lambda { |request|
  tenant_id = request.params['tenant_id'] || request.session[:tenant_id]

  if tenant_id.present?
    tenant_name = "tenant_#{tenant_id}"
    if Apartment.tenant_names.include?(tenant_name)
      tenant_name
    else
      Rails.logger.error("Invalid tenant ID: #{tenant_id}")
    end
  else
    Rails.logger.error("Tenant ID missing")
    nil
  end
}
