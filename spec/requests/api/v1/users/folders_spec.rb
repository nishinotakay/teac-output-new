# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users::Folders', type: :request do
  def user_auth_headers(user)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" }
  end

  def folder_names_and_counts
    JSON.parse(response.body)['folders'].map { |folder| [folder['name'], folder['articlesCount']] }
  end

  let(:tenant) { create(:tenant) }
  let(:current_user) { create(:user, tenant: tenant) }
  let(:other_user) { create(:user, tenant: tenant) }
  let(:default_folder) { current_user.folders.find_by!(name: '未分類') }
  let(:ruby_folder) { current_user.folders.create!(name: 'Ruby') }
  let(:other_users_folder) { other_user.folders.create!(name: '他人のフォルダ') }

  describe 'GET /api/v1/folders' do
    it '未ログインなら 401 を返す' do
      get '/api/v1/folders'

      expect(response).to have_http_status(:unauthorized)
    end

    it '自分のフォルダだけを「未分類」から順に、記事数付きで返す' do
      create(:article, user: current_user).move_to_folder!(ruby_folder)
      create(:article, user: current_user)
      other_users_folder

      get '/api/v1/folders', headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(folder_names_and_counts).to eq([['未分類', 1], ['Ruby', 1]])
    end

    it 'フォルダ行が無い自分の記事を「未分類」の記事数に入れる' do
      article = create(:article, user: current_user)
      ArticleFolder.where(article_id: article.id).delete_all

      get '/api/v1/folders', headers: user_auth_headers(current_user)

      expect(folder_names_and_counts).to eq([['未分類', 1]])
    end

    it '「未分類」が無い受講生には作成し、先頭で返す' do
      Folder.where(user_id: current_user.id).delete_all
      ruby_folder

      get '/api/v1/folders', headers: user_auth_headers(current_user)

      expect(folder_names_and_counts).to eq([['未分類', 0], ['Ruby', 0]])
      expect(JSON.parse(response.body)['folders'].first['isDefault']).to be(true)
    end
  end

  describe 'POST /api/v1/folders' do
    it 'フォルダを作成して 201 を返す' do
      post '/api/v1/folders', params: { name: 'Ruby' }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['folder']).to include('name' => 'Ruby', 'isDefault' => false, 'articlesCount' => 0)
      expect(current_user.folders.exists?(name: 'Ruby')).to be(true)
    end

    it '他の受講生のフォルダと同じ名前なら作成できる' do
      other_users_folder

      post '/api/v1/folders', params: { name: '他人のフォルダ' }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:created)
    end

    [
      ['空', ''],
      ['31 文字', 'あ' * 31],
      ['「未分類」と同じ', '未分類'],
      ['既存のフォルダと同じ', 'Ruby']
    ].each do |label, name|
      it "名前が#{label}なら 422 を返し、作成しない" do
        ruby_folder

        post '/api/v1/folders', params: { name: name }, headers: user_auth_headers(current_user)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(current_user.folders.count).to eq(2)
      end
    end
  end

  describe 'PATCH /api/v1/folders/:id' do
    it '名前を変更して 200 を返す' do
      patch "/api/v1/folders/#{ruby_folder.id}", params: { name: 'Rails' }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(ruby_folder.reload.name).to eq('Rails')
    end

    it '他の受講生のフォルダなら 404 を返し、名前を変えない' do
      patch "/api/v1/folders/#{other_users_folder.id}", params: { name: '乗っ取り' }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
      expect(other_users_folder.reload.name).to eq('他人のフォルダ')
    end

    it '「未分類」なら 422 を返し、名前を変えない' do
      patch "/api/v1/folders/#{default_folder.id}", params: { name: 'その他' }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(default_folder.reload.name).to eq('未分類')
    end
  end

  describe 'DELETE /api/v1/folders/:id' do
    it 'フォルダを消し、中の記事を「未分類」へ移す' do
      article = create(:article, user: current_user)
      article.move_to_folder!(ruby_folder)

      delete "/api/v1/folders/#{ruby_folder.id}", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(Folder.exists?(ruby_folder.id)).to be(false)
      expect(article.reload.folders).to eq([default_folder])
    end

    it '他の受講生のフォルダなら 404 を返し、消さない' do
      delete "/api/v1/folders/#{other_users_folder.id}", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
      expect(Folder.exists?(other_users_folder.id)).to be(true)
    end

    it '「未分類」なら 422 を返し、消さない' do
      delete "/api/v1/folders/#{default_folder.id}", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(Folder.exists?(default_folder.id)).to be(true)
    end
  end
end
