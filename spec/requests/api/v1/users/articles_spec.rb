# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users::Articles', type: :request do
  def user_auth_headers(user)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" }
  end

  def like_article(user, target_article)
    create(:like, user_id: user.id, article_id: target_article.id)
  end

  # 記事はテナントで絞られるため、受講生 2 人を同じテナントに揃える
  let(:tenant) { create(:tenant) }
  let(:current_user) { create(:user, tenant: tenant) }
  let(:other_user) { create(:user, tenant: tenant) }
  let(:article) { create(:article, user: other_user) }

  describe 'GET /api/v1/articles/:id' do
    it 'いいねが 0 件なら likesCount 0・likedByCurrentUser false を返す' do
      get "/api/v1/articles/#{article.id}", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['article']).to include('likesCount' => 0, 'likedByCurrentUser' => false)
    end

    it '自分がいいね済みなら likesCount 1・likedByCurrentUser true を返す' do
      like_article(current_user, article)

      get "/api/v1/articles/#{article.id}", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['article']).to include('likesCount' => 1, 'likedByCurrentUser' => true)
    end

    it '他の受講生だけがいいねしていれば likesCount 1・likedByCurrentUser false を返す' do
      like_article(other_user, article)

      get "/api/v1/articles/#{article.id}", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['article']).to include('likesCount' => 1, 'likedByCurrentUser' => false)
    end
  end

  describe 'GET /api/v1/articles' do
    it '記事ごとのいいね数と自分のいいね状態を返す' do
      liked_article = create(:article, user: other_user)
      like_article(current_user, liked_article)
      like_article(other_user, liked_article)
      like_article(other_user, article)

      get '/api/v1/articles', headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      articles_by_id = JSON.parse(response.body)['articles'].index_by { |article_row| article_row['id'] }
      expect(articles_by_id[liked_article.id.to_s]).to include('likesCount' => 2, 'likedByCurrentUser' => true)
      expect(articles_by_id[article.id.to_s]).to include('likesCount' => 1, 'likedByCurrentUser' => false)
    end
  end
end
