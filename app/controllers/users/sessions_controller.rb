module Users
  class SessionsController < Devise::SessionsController
    layout 'users_auth'

    def create
      if params[:tenant_id].present? || session[:tenant_id].present?
        tenant_id = session[:tenant_id] || params[:tenant_id]
        tenant_name = "tenant_#{tenant_id}"
      begin
        Apartment::Tenant.switch!(tenant_name)
        Rails.logger.info("Switched to Tenant: #{Apartment::Tenant.current}")
        session[:tenant_id] = tenant_id
      rescue Apartment::TenantNotFound => e
        Rails.logger.error("Tenant not found: #{tenant_name}")
        render :new, alert: "Tenant not found"
        return
      end
      end

      super
    end
  end
end
