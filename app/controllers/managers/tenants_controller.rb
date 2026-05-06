# マネージャー向けテナント管理コントローラ: スクール（テナント）の一覧・新規作成・詳細表示・削除を管理する

module Managers
  class TenantsController < Managers::Base
    before_action :set_tenant, only: %i[show destroy]

    # テナント一覧をページネーション付きで表示する
    def index
      @tenants = Tenant.page(params[:page]).per(30)
    end

    # 新規テナント登録フォームを表示する
    def new
      @tenant = Tenant.new
    end

    # 新規テナントを保存する
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

    # テナント詳細を表示する
    def show; end

    # テナントを削除する
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

