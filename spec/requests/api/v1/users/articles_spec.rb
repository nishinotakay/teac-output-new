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

  describe 'PATCH /api/v1/articles/:id/folder' do
    let(:own_article) { create(:article, user: current_user) }
    let(:ruby_folder) { current_user.folders.create!(name: 'Ruby') }

    it '未ログインなら 401 を返す' do
      patch "/api/v1/articles/#{own_article.id}/folder", params: { folder_id: ruby_folder.id }

      expect(response).to have_http_status(:unauthorized)
    end

    it '自分の記事を自分のフォルダへ移し、folderId を返す' do
      patch "/api/v1/articles/#{own_article.id}/folder", params: { folder_id: ruby_folder.id }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['article']['folderId']).to eq(ruby_folder.id.to_s)
      expect(own_article.reload.folders).to eq([ruby_folder])
    end

    it 'フォルダ行が無い自分の記事も移せる' do
      ArticleFolder.where(article_id: own_article.id).delete_all

      patch "/api/v1/articles/#{own_article.id}/folder", params: { folder_id: ruby_folder.id }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(own_article.reload.folders).to eq([ruby_folder])
    end

    it '他の受講生の記事なら 403 を返し、フォルダを変えない' do
      folders_before = article.folders.to_a

      patch "/api/v1/articles/#{article.id}/folder", params: { folder_id: ruby_folder.id }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:forbidden)
      expect(article.reload.folders).to eq(folders_before)
    end

    it '他の受講生のフォルダなら 404 を返し、フォルダを変えない' do
      other_users_folder = other_user.folders.create!(name: '他人のフォルダ')
      folders_before = own_article.folders.to_a

      patch "/api/v1/articles/#{own_article.id}/folder", params: { folder_id: other_users_folder.id }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
      expect(own_article.reload.folders).to eq(folders_before)
    end

    it '他テナントの記事なら 404 を返し、フォルダを変えない' do
      other_tenant_article = create(:article, user: create(:user, tenant: create(:tenant)))
      folders_before = other_tenant_article.folders.to_a

      patch "/api/v1/articles/#{other_tenant_article.id}/folder", params: { folder_id: ruby_folder.id }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
      expect(other_tenant_article.reload.folders).to eq(folders_before)
    end
  end

  describe 'folderId' do
    let(:default_folder_id) { current_user.folders.find_by!(name: '未分類').id.to_s }

    it '一覧では、自分の記事はフォルダの id、他の受講生の記事は null を返す' do
      own_article = create(:article, user: current_user)
      article

      get '/api/v1/articles', headers: user_auth_headers(current_user)

      folder_ids = JSON.parse(response.body)['articles'].to_h { |article_json| [article_json['id'], article_json['folderId']] }
      expect(folder_ids).to eq(own_article.id.to_s => default_folder_id, article.id.to_s => nil)
    end

    it 'フォルダ行が無い自分の記事は「未分類」の id を返し、GET では行を作らない' do
      own_article = create(:article, user: current_user)
      ArticleFolder.where(article_id: own_article.id).delete_all

      get "/api/v1/articles/#{own_article.id}", headers: user_auth_headers(current_user)

      expect(JSON.parse(response.body)['article']['folderId']).to eq(default_folder_id)
      expect(ArticleFolder.exists?(article_id: own_article.id)).to be(false)
    end
  end
end
