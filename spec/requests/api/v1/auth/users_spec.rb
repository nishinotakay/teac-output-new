# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Auth::Users', type: :request do
  let(:tenant_a) { create(:tenant, name: 'テナントA') }
  let(:tenant_b) { create(:tenant, name: 'テナントB') }
  # signup はまだ プロアカ を選択させる導線がないため、システムに存在する最初の Proaka に自動で紐付く。
  # 本番では db:seed で必ず1件存在する前提。
  let!(:default_proaka) { create(:proaka, name: 'プロアカ1') }

  describe 'POST /api/v1/auth/login' do
    let!(:user) { create(:user, email: 'taro@example.com', password: 'password', tenant: tenant_a) }

    context '自分の所属テナントでログインした場合' do
      it 'トークンとユーザー情報を返す' do
        post '/api/v1/auth/login', params: { email: user.email, password: 'password', tenant_id: tenant_a.id }

        expect(response).to have_http_status(:ok)
        body = JSON.parse(response.body)
        expect(body['token']).to be_present
        expect(body['user']['email']).to eq(user.email)
      end
    end

    context '別テナントのIDでログインした場合' do
      it '401 を返す（テナントを跨いだログインはできない）' do
        post '/api/v1/auth/login', params: { email: user.email, password: 'password', tenant_id: tenant_b.id }

        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['error']).to be_present
      end
    end

    context 'tenant_id を指定しない場合' do
      it '401 を返す' do
        post '/api/v1/auth/login', params: { email: user.email, password: 'password' }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'パスワードが違う場合' do
      it '401 を返す' do
        post '/api/v1/auth/login', params: { email: user.email, password: 'wrongpassword', tenant_id: tenant_a.id }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/v1/auth/signup' do
    context '有効な tenant_id を指定した場合' do
      it 'ユーザーを作成し、指定した tenant に紐付ける' do
        expect do
          post '/api/v1/auth/signup', params: {
            name: 'テスト太郎',
            email: 'newuser@example.com',
            password: 'password',
            password_confirmation: 'password',
            tenant_id: tenant_a.id
          }
        end.to change(User, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(User.last.tenant_id).to eq(tenant_a.id)
      end
    end

    context 'tenant_id を指定しない場合' do
      it '422 を返し、ユーザーを作成しない' do
        expect do
          post '/api/v1/auth/signup', params: {
            name: 'テスト太郎',
            email: 'newuser2@example.com',
            password: 'password',
            password_confirmation: 'password'
          }
        end.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context '存在しない tenant_id を指定した場合' do
      it '422 を返し、ユーザーを作成しない' do
        expect do
          post '/api/v1/auth/signup', params: {
            name: 'テスト太郎',
            email: 'newuser3@example.com',
            password: 'password',
            password_confirmation: 'password',
            tenant_id: 999_999
          }
        end.not_to change(User, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
