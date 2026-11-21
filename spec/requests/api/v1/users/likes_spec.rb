require 'rails_helper'

RSpec.describe 'Api::V1::Users::Likes（動画）' do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:headers) { { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" } }
  let(:own_post) { create(:post, user: user, admin: create(:admin, tenant: tenant)) }

  let(:foreign_tenant) { create(:tenant) }
  let(:foreign_post) do
    create(:post, user: create(:user, tenant: foreign_tenant), admin: create(:admin, tenant: foreign_tenant))
  end

  describe 'POST /api/v1/posts/:post_id/likes' do
    it '同一テナントの動画にいいねできる（201）' do
      expect { post "/api/v1/posts/#{own_post.id}/likes", headers: headers }
        .to change(Like, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)).to eq('liked' => true)
    end

    it '他テナントの動画は 404 で Like.count が変わらない' do
      foreign_post
      expect { post "/api/v1/posts/#{foreign_post.id}/likes", headers: headers }
        .not_to change(Like, :count)

      expect(response).to have_http_status(:not_found)
    end

    it '未認証は 401' do
      post "/api/v1/posts/#{own_post.id}/likes"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/v1/posts/:post_id/likes' do
    it '自分のいいねを解除できる' do
      create(:like, user_id: user.id, article_id: nil, post_id: own_post.id)

      expect { delete "/api/v1/posts/#{own_post.id}/likes", headers: headers }
        .to change(Like, :count).by(-1)

      expect(response).to have_http_status(:ok)
    end

    it '他テナントの動画は 404 で Like.count が変わらない' do
      foreign_post
      expect { delete "/api/v1/posts/#{foreign_post.id}/likes", headers: headers }
        .not_to change(Like, :count)

      expect(response).to have_http_status(:not_found)
    end
  end
end
