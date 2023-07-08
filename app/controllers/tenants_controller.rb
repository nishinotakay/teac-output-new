class TenantsController < ApplicationController
  def index
    @tenants = Tenant.all
  end

  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new(tenant_params)
    if @tenant.save
      flash.now[:success] = "#{@tenant.name}を登録しました。"
      redirect_to :index
    else
      flash.now[:danger] = '登録できませんでした。やり直してください。'
      render :new
    end
  end

  def destroy
    @tenant = Tenant.find(params[:id])
    if @tenant.destroy!
      flash.now[:warning] = "#{@tenant.name}を削除しました。"
    end
    render :index
  end

  private

    def tenant_params
      params.require(:tenant).permit(:name)
    end
end
