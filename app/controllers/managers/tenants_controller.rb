module Managers
  class TenantsController < Managers::Base
    before_action :set_tenant, only: %i[show destroy]

    def index
      @tenants = Tenant.page(params[:page]).per(30)
    end

    def new
      @tenant = Tenant.new
    end

    def create
      @tenant = Tenant.new(tenant_params)
      if @tenant.save
        flash[:notice] = "#{@tenant.name}を登録しました。"
        redirect_to managers_tenants_url
      else
        flash.now[:notice] = '登録できませんでした。やり直してください。'
        render :new
      end
    end

    def show; end

    def destroy
      if @tenant.destroy!
        flash[:notice] = "#{@tenant.name}を削除しました。"
      end
      redirect_to managers_tenants_url
    end

    private

      def tenant_params
        params.require(:tenant).permit(:name)
      end

      def set_tenant
        @tenant = Tenant.find(params[:id])
      end
  end
end
