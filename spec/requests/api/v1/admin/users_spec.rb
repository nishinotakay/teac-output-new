# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Users', type: :request do
  let(:tenant_a) { create(:tenant, name: 'テナントA') }
  let(:tenant_b) { create(:tenant, name: 'テナントB') }
  let!(:admin_a) { create(:admin, tenant: tenant_a) }
  let!(:user_a)  { create(:user, tenant: tenant_a) }
  let!(:user_b)  { create(:user, tenant: tenant_b) }

  def auth_headers_for(admin)
    token = JwtHelper.encode(id: admin.id, role: 'admin')
    { 'Authorization' => "Bearer #{token}" }
  end

  def user_auth_headers_for(user)
    token = JwtHelper.encode(id: user.id, role: 'user')
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'GET /api/v1/admin/users' do
    it '自分のテナントのユーザーのみが一覧に含まれる' do
      get '/api/v1/admin/users', headers: auth_headers_for(admin_a)

      ids = JSON.parse(response.body)['users'].map { |u| u['id'] }
      expect(ids).to include(user_a.id.to_s)
      expect(ids).not_to include(user_b.id.to_s)
    end

    it '解約済みの受講生は cancelledAt に日時、利用中は null が入る' do
      user_a.update!(cancelled_at: Time.zone.local(2026, 11, 10, 10, 0, 0))
      other_user_a = create(:user, tenant: tenant_a)

      get '/api/v1/admin/users', headers: auth_headers_for(admin_a)

      users_by_id = JSON.parse(response.body)['users'].index_by { |user_row| user_row['id'] }
      expect(users_by_id[user_a.id.to_s]['cancelledAt']).to eq('2026-11-10T10:00:00+09:00')
      expect(users_by_id[other_user_a.id.to_s]['cancelledAt']).to be_nil
    end
  end

  describe 'GET /api/v1/admin/users/:id' do
    it '他テナントのユーザーIDを指定すると見つからない（404）' do
      get "/api/v1/admin/users/#{user_b.id}", headers: auth_headers_for(admin_a)

      expect(response).to have_http_status(:not_found)
    end

    it '自テナントのユーザーIDなら取得できる' do
      get "/api/v1/admin/users/#{user_a.id}", headers: auth_headers_for(admin_a)

      expect(response).to have_http_status(:ok)
    end

    it '詳細にも cancelledAt が入る' do
      user_a.update!(cancelled_at: Time.zone.local(2026, 11, 10, 10, 0, 0))

      get "/api/v1/admin/users/#{user_a.id}", headers: auth_headers_for(admin_a)

      expect(JSON.parse(response.body)['user']['cancelledAt']).to eq('2026-11-10T10:00:00+09:00')
    end
  end

  describe 'DELETE /api/v1/admin/users/:id' do
    it '他テナントのユーザーは削除できない（404で、実際に削除もされない）' do
      expect do
        delete "/api/v1/admin/users/#{user_b.id}", headers: auth_headers_for(admin_a)
      end.not_to change(User.unscoped, :count)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/v1/admin/users/:id/cancel' do
    let(:first_cancelled_at) { Time.zone.local(2026, 11, 1, 9, 0, 0) }

    it '自テナントの受講生を解約すると 200 で cancelledAt が入る' do
      patch "/api/v1/admin/users/#{user_a.id}/cancel", headers: auth_headers_for(admin_a)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['user']['cancelledAt']).to be_present
      expect(user_a.reload.cancelled_at).to be_present
    end

    it 'すでに解約済みなら 200 で、最初の解約日時のまま' do
      user_a.update!(cancelled_at: first_cancelled_at)

      patch "/api/v1/admin/users/#{user_a.id}/cancel", headers: auth_headers_for(admin_a)

      expect(response).to have_http_status(:ok)
      expect(user_a.reload.cancelled_at).to eq(first_cancelled_at)
    end

    it '他テナントの受講生は 404 で、解約されない' do
      patch "/api/v1/admin/users/#{user_b.id}/cancel", headers: auth_headers_for(admin_a)

      expect(response).to have_http_status(:not_found)
      expect(user_b.reload.cancelled_at).to be_nil
    end

    it '未ログインは 401 で、解約されない' do
      patch "/api/v1/admin/users/#{user_a.id}/cancel"

      expect(response).to have_http_status(:unauthorized)
      expect(user_a.reload.cancelled_at).to be_nil
    end

    it '受講生のトークンは 401 で、解約されない' do
      patch "/api/v1/admin/users/#{user_a.id}/cancel", headers: user_auth_headers_for(user_a)

      expect(response).to have_http_status(:unauthorized)
      expect(user_a.reload.cancelled_at).to be_nil
    end
  end

  describe 'PATCH /api/v1/admin/users/:id/resume' do
    let(:cancelled_at) { Time.zone.local(2026, 11, 1, 9, 0, 0) }

    it '解約済みの受講生を再開すると 200 で cancelledAt が null に戻る' do
      user_a.update!(cancelled_at: cancelled_at)

      patch "/api/v1/admin/users/#{user_a.id}/resume", headers: auth_headers_for(admin_a)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['user']['cancelledAt']).to be_nil
      expect(user_a.reload.cancelled_at).to be_nil
    end

    it 'まだ解約していない受講生を再開しても 200 で何も変わらない' do
      expect do
        patch "/api/v1/admin/users/#{user_a.id}/resume", headers: auth_headers_for(admin_a)
      end.not_to(change { user_a.reload.updated_at })

      expect(response).to have_http_status(:ok)
      expect(user_a.reload.cancelled_at).to be_nil
    end

    it '他テナントの受講生は 404 で、再開されない' do
      user_b.update!(cancelled_at: cancelled_at)

      patch "/api/v1/admin/users/#{user_b.id}/resume", headers: auth_headers_for(admin_a)

      expect(response).to have_http_status(:not_found)
      expect(user_b.reload.cancelled_at).to eq(cancelled_at)
    end
  end
end
