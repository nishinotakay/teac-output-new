# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Manager::Tenants', type: :request do
  let!(:proaka) { create(:proaka) }
  let(:manager) do
    Manager.create!(name: 'マネージャー', email: 'manager@example.com', password: 'password',
                    password_confirmation: 'password', confirmed_at: Time.current)
  end

  def auth_headers_for(manager)
    token = JwtHelper.encode(id: manager.id, role: 'manager')
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'POST /api/v1/manager/tenants' do
    let(:params) do
      {
        name: '新テナント',
        admin_name: '新管理者',
        admin_email: 'New-Admin@example.com',
        admin_password: 'password',
        admin_password_confirmation: 'password'
      }
    end

    it 'テナントと管理者を作成し、管理者は新テナントに所属する' do
      expect do
        post '/api/v1/manager/tenants', params: params, headers: auth_headers_for(manager)
      end.to change(Tenant, :count).by(1).and change(Admin.unscoped, :count).by(1)

      expect(response).to have_http_status(:created)
      tenant = Tenant.find(JSON.parse(response.body)['tenant']['id'])
      admin = Admin.unscoped.find_by(email: 'new-admin@example.com')
      expect(admin.tenant).to eq(tenant)
      expect(admin.name).to eq('新管理者')
      expect(admin).to be_confirmed
    end

    it '作成した管理者でログインできる' do
      post '/api/v1/manager/tenants', params: params, headers: auth_headers_for(manager)

      post '/api/v1/admin/auth/login', params: { email: 'new-admin@example.com', password: 'password' }
      expect(response).to have_http_status(:ok)
    end

    it '管理者の入力が不正ならテナントも作成されない（422）' do
      invalid = params.merge(admin_password_confirmation: 'different')

      expect do
        post '/api/v1/manager/tenants', params: invalid, headers: auth_headers_for(manager)
      end.not_to change(Tenant, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to be_present
    end

    it '管理者のメールアドレスが既存と重複するとテナントも作成されない（422）' do
      create(:admin, email: 'new-admin@example.com')

      expect do
        post '/api/v1/manager/tenants', params: params, headers: auth_headers_for(manager)
      end.not_to change(Tenant, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'テナント名が不正なら管理者も作成されない（422）' do
      expect do
        post '/api/v1/manager/tenants', params: params.merge(name: ''), headers: auth_headers_for(manager)
      end.not_to change(Admin.unscoped, :count)

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it '未認証なら401' do
      post '/api/v1/manager/tenants', params: params

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
