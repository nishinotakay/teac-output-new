require 'apartment/elevators/generic'

Apartment.configure do |config|
  # マルチテナント化しないモデルを設定
  config.excluded_models = %w{ Tenant }

  # パブリックスキーマへのフォールバックを無効
  config.default_tenant = false

  # 切り替え対象のテナント名をApartmentに設定
  config.tenant_names = lambda { Tenant.pluck(:name) }

  # テナントごとに個別のスキーマを使用
  config.use_schemas = true
end

# リクエストごとに有効なテナント名であるかをチェック。有効な場合はそのテナント名をApartmentで使用可能にする
Rails.application.config.middleware.use Apartment::Elevators::Generic, lambda { |request|
  tenant_id = request.params['tenant_id'] || request.session[:tenant_id]
  
  if tenant_id.present?
    tenant = Tenant.find_by(id: tenant_id)
    if tenant && tenant.name.present? && Apartment.tenant_names.include?(tenant.name)
      tenant.name
    end
  end
}
