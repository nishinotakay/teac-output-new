module Users
  class SessionsController < Devise::SessionsController
    layout 'users_auth'

    def create
      tenant_id = session[:tenant_id] || params[:tenant_id] || current_user&.tenant_id

      # テナント名を取得
      tenant_name = "tenant_#{tenant_id}"

      # テナントの切り替え
      if tenant_name.present?
        begin
          Apartment::Tenant.switch!(tenant_name)
          Rails.logger.info("Switched to Tenant: #{Apartment::Tenant.current}")
        rescue Apartment::TenantNotFound => e
          Rails.logger.error("Tenant not found: #{tenant_name}")
          render :new, alert: "Tenant not found"
          return
        end
      else
        Rails.logger.error("Tenant ID is missing")
      end

      # ログイン処理の後にテナントIDをセッションに保存
      super do |resource|
        session[:tenant_id] = tenant_id
      end
    end
  end
end
