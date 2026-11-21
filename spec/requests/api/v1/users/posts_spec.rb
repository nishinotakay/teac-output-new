require 'rails_helper'

RSpec.describe 'Api::V1::Users::Posts', type: :request do
  def user_auth_headers(user)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" }
  end

  def returned_post_ids
    JSON.parse(response.body)['posts'].map { |post| post['id'] }
  end

  let(:tenant) { create(:tenant) }
  let(:other_tenant) { create(:tenant) }
  let(:current_user) { create(:user, tenant: tenant) }
  let(:headers) { user_auth_headers(current_user) }
  let(:valid_params) do
    { title: '新しい動画', body: '説明', youtube_url: 'https://www.youtube.com/watch?v=abc' }
  end

  # 他テナントの受講生・管理者の動画
  let(:foreign_user) { create(:user, tenant: other_tenant) }
  let(:foreign_admin) { create(:admin, tenant: other_tenant) }
  let!(:foreign_user_post) { create(:post, user: foreign_user, admin: nil) }
  let!(:foreign_admin_post) { create(:post, user: nil, admin: foreign_admin) }

  describe 'GET /api/v1/posts' do
    it 'トークン無しは 401' do
      get '/api/v1/posts'
      expect(response).to have_http_status(:unauthorized)
    end

    it '自分の動画だけを新着順で返し、他テナントの動画を含まない' do
      older = create(:post, user: current_user, admin: nil, created_at: 2.days.ago)
      newer = create(:post, user: current_user, admin: nil, created_at: 1.day.ago)

      get '/api/v1/posts', headers: headers

      expect(response).to have_http_status(:ok)
      expect(returned_post_ids).to eq([newer.id.to_s, older.id.to_s])
      expect(returned_post_ids).not_to include(foreign_user_post.id.to_s, foreign_admin_post.id.to_s)
    end
  end

  describe 'GET /api/v1/posts/:id' do
    it '自テナントの動画は 200' do
      own = create(:post, user: current_user, admin: nil)
      get "/api/v1/posts/#{own.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['post']['id']).to eq(own.id.to_s)
    end

    it '他テナントの id は 404' do
      get "/api/v1/posts/#{foreign_user_post.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/posts' do
    it 'トークン無しは 401 で DB 不変' do
      expect { post '/api/v1/posts', params: valid_params }.not_to(change { Post.unscoped.count })
      expect(response).to have_http_status(:unauthorized)
    end

    it '201 で作成し、tenant_id がログイン主体のテナントになる' do
      expect { post '/api/v1/posts', params: valid_params, headers: headers }
        .to change { Post.unscoped.count }.by(1)

      expect(response).to have_http_status(:created)
      created = Post.unscoped.find(JSON.parse(response.body)['post']['id'])
      expect(created.tenant_id).to eq(tenant.id)
      expect(created.user_id).to eq(current_user.id)
    end

    it '不正な入力は 422' do
      post '/api/v1/posts', params: valid_params.merge(title: ''), headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/v1/posts/:id' do
    it '自分の動画は更新できる' do
      own = create(:post, user: current_user, admin: nil)
      patch "/api/v1/posts/#{own.id}", params: { title: '更新後' }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(own.reload.title).to eq('更新後')
    end

    it '同テナントの他人の動画は 403 で DB 不変' do
      colleague = create(:user, tenant: tenant)
      others = create(:post, user: colleague, admin: nil)
      expect { patch "/api/v1/posts/#{others.id}", params: { title: '改ざん' }, headers: headers }
        .not_to(change { others.reload.title })
      expect(response).to have_http_status(:forbidden)
    end

    it '他テナントの id は 404 で DB 不変' do
      expect { patch "/api/v1/posts/#{foreign_user_post.id}", params: { title: '改ざん' }, headers: headers }
        .not_to(change { Post.unscoped.find(foreign_user_post.id).title })
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/posts/:id' do
    it '自分の動画は削除できる' do
      own = create(:post, user: current_user, admin: nil)
      expect { delete "/api/v1/posts/#{own.id}", headers: headers }.to change { Post.unscoped.count }.by(-1)
      expect(response).to have_http_status(:ok)
    end

    it '同テナントの他人の動画は 403 で DB 不変' do
      others = create(:post, user: create(:user, tenant: tenant), admin: nil)
      expect { delete "/api/v1/posts/#{others.id}", headers: headers }.not_to(change { Post.unscoped.count })
      expect(response).to have_http_status(:forbidden)
    end

    it '他テナントの id は 404 で DB 不変' do
      expect { delete "/api/v1/posts/#{foreign_user_post.id}", headers: headers }
        .not_to(change { Post.unscoped.count })
      expect(response).to have_http_status(:not_found)
    end
  end
end
