class Api::V1::Manager::TenantsController < Api::V1::BaseController
  before_action :authenticate_manager!
  before_action :set_tenant, only: [:show]

  # GET /api/v1/manager/tenants
  def index
    tenants = Tenant.order(:id)
    render json: { tenants: tenants.map { |t| tenant_json(t) } }
  end

  # GET /api/v1/manager/tenants/:id
  def show
    render json: { tenant: tenant_json(@tenant) }
  end

  # POST /api/v1/manager/tenants
  # テナントと、そのテナントの最初の管理者を同一トランザクションで作成する。
  def create
    tenant = Tenant.new(tenant_params)
    admin = tenant.admins.build(admin_params)
    admin.proaka ||= Proaka.order(:id).first # auth/users#signup と同じ
    admin.skip_confirmation! # confirmable をスキップして即有効化（auth/users#signup と同じ）

    ActiveRecord::Base.transaction do
      tenant.save!
      admin.save!
    end
    render json: { tenant: tenant_json(tenant) }, status: :created
  rescue ActiveRecord::RecordInvalid => e
    render json: { errors: e.record.errors.full_messages }, status: :unprocessable_entity
  end

  private

  def set_tenant
    @tenant = Tenant.find_by(id: params[:id])
    render_not_found('テナント') unless @tenant
  end

  def tenant_params
    params.permit(:name)
  end

  def admin_params
    {
      name: params[:admin_name],
      email: params[:admin_email]&.downcase,
      password: params[:admin_password],
      password_confirmation: params[:admin_password_confirmation]
    }
  end

  def tenant_json(tenant)
    {
      id: tenant.id.to_s,
      name: tenant.name,
      createdAt: tenant.created_at.iso8601
    }
  end
end
