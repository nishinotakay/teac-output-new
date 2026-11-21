require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Posts', type: :request do
  def admin_auth_headers(admin)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" }
  end

  def user_auth_headers(user)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" }
  end

  def returned_post_ids
    JSON.parse(response.body)['posts'].map { |post| post['id'] }
  end

  let(:tenant) { create(:tenant) }
  let(:other_tenant) { create(:tenant) }
  let(:current_admin) { create(:admin, tenant: tenant) }
  let(:headers) { admin_auth_headers(current_admin) }
  let(:valid_params) do
    { title: '講師の動画', body: '説明', youtube_url: 'https://www.youtube.com/watch?v=abc' }
  end

  let(:student) { create(:user, tenant: tenant) }
  let(:foreign_user) { create(:user, tenant: other_tenant) }
  let(:foreign_admin) { create(:admin, tenant: other_tenant) }
  let!(:foreign_user_post) { create(:post, user: foreign_user, admin: nil) }
  let!(:foreign_admin_post) { create(:post, user: nil, admin: foreign_admin) }

  describe 'GET /api/v1/admin/posts' do
    it 'トークン無しは 401' do
      get '/api/v1/admin/posts'
      expect(response).to have_http_status(:unauthorized)
    end

    it '受講生トークンは 401' do
      get '/api/v1/admin/posts', headers: user_auth_headers(student)
      expect(response).to have_http_status(:unauthorized)
    end

    it '自テナントの動画（講師・受講生）だけを新着順で返し、他テナントを含まない' do
      student_post = create(:post, user: student, admin: nil, created_at: 2.days.ago)
      admin_post = create(:post, user: nil, admin: current_admin, created_at: 1.day.ago)

      get '/api/v1/admin/posts', headers: headers

      expect(response).to have_http_status(:ok)
      expect(returned_post_ids).to eq([admin_post.id.to_s, student_post.id.to_s])
      expect(returned_post_ids).not_to include(foreign_user_post.id.to_s, foreign_admin_post.id.to_s)
    end
  end

  describe 'GET /api/v1/admin/posts/:id' do
    it '自テナントの受講生の動画は 200' do
      student_post = create(:post, user: student, admin: nil)
      get "/api/v1/admin/posts/#{student_post.id}", headers: headers
      expect(response).to have_http_status(:ok)
    end

    it '他テナントの id は 404' do
      get "/api/v1/admin/posts/#{foreign_user_post.id}", headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/admin/posts' do
    it 'トークン無しは 401 で DB 不変' do
      expect { post '/api/v1/admin/posts', params: valid_params }.not_to(change { Post.unscoped.count })
      expect(response).to have_http_status(:unauthorized)
    end

    it '201 で作成し、tenant_id がログイン管理者のテナントになる' do
      expect { post '/api/v1/admin/posts', params: valid_params, headers: headers }
        .to change { Post.unscoped.count }.by(1)

      expect(response).to have_http_status(:created)
      created = Post.unscoped.find(JSON.parse(response.body)['post']['id'])
      expect(created.tenant_id).to eq(tenant.id)
      expect(created.admin_id).to eq(current_admin.id)
    end
  end

  describe 'PATCH /api/v1/admin/posts/:id' do
    it '自分の動画は更新できる' do
      own = create(:post, user: nil, admin: current_admin)
      patch "/api/v1/admin/posts/#{own.id}", params: { title: '更新後' }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(own.reload.title).to eq('更新後')
    end

    it '同テナントの受講生の動画は更新できる' do
      student_post = create(:post, user: student, admin: nil)
      patch "/api/v1/admin/posts/#{student_post.id}", params: { title: '管理者が更新' }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(student_post.reload.title).to eq('管理者が更新')
    end

    it '同テナントの別管理者の動画は 403 で DB 不変' do
      colleague = create(:admin, tenant: tenant)
      others = create(:post, user: nil, admin: colleague)
      expect { patch "/api/v1/admin/posts/#{others.id}", params: { title: '改ざん' }, headers: headers }
        .not_to(change { others.reload.title })
      expect(response).to have_http_status(:forbidden)
    end

    it '他テナントの id は 404 で DB 不変' do
      [foreign_user_post, foreign_admin_post].each do |foreign_post|
        expect { patch "/api/v1/admin/posts/#{foreign_post.id}", params: { title: '改ざん' }, headers: headers }
          .not_to(change { Post.unscoped.find(foreign_post.id).title })
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'DELETE /api/v1/admin/posts/:id' do
    it '自分の動画は削除できる' do
      own = create(:post, user: nil, admin: current_admin)
      expect { delete "/api/v1/admin/posts/#{own.id}", headers: headers }.to change { Post.unscoped.count }.by(-1)
      expect(response).to have_http_status(:ok)
    end

    it '同テナントの受講生の動画は削除できる' do
      student_post = create(:post, user: student, admin: nil)
      expect { delete "/api/v1/admin/posts/#{student_post.id}", headers: headers }
        .to change { Post.unscoped.count }.by(-1)
    end

    it '同テナントの別管理者の動画は 403 で DB 不変' do
      others = create(:post, user: nil, admin: create(:admin, tenant: tenant))
      expect { delete "/api/v1/admin/posts/#{others.id}", headers: headers }.not_to(change { Post.unscoped.count })
      expect(response).to have_http_status(:forbidden)
    end

    it '他テナントの id は 404 で DB 不変' do
      [foreign_user_post, foreign_admin_post].each do |foreign_post|
        expect { delete "/api/v1/admin/posts/#{foreign_post.id}", headers: headers }
          .not_to(change { Post.unscoped.count })
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
