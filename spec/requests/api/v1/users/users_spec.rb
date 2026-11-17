# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users::Users' do
  def user_auth_headers(user)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" }
  end

  def admin_auth_headers(admin)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" }
  end

  def response_json
    JSON.parse(response.body)
  end

  let(:tenant) { create(:tenant) }
  let!(:current_user) { create(:user, tenant: tenant, name: '自分') }
  let(:classmate) { create(:user, tenant: tenant, name: '同じスクールの受講生') }

  describe 'GET /api/v1/users' do
    it '未ログインなら 401 を返す' do
      get '/api/v1/users'

      expect(response).to have_http_status(:unauthorized)
    end

    it '講師のトークンなら 401 を返す' do
      get '/api/v1/users', headers: admin_auth_headers(create(:admin, tenant: tenant))

      expect(response).to have_http_status(:unauthorized)
    end

    it '同じスクールの解約していない受講生を、自分も含めて登録順に返し、メールアドレスは出さない' do
      current_user.active_relationships.create!(followed: classmate)
      create(:user, tenant: tenant, cancelled_at: Time.current)
      create(:user, tenant: create(:tenant))

      get '/api/v1/users', headers: user_auth_headers(current_user)

      expect(response_json['users']).to eq [
        { 'id' => current_user.id.to_s, 'name' => '自分', 'followedByCurrentUser' => false, 'isCurrentUser' => true },
        { 'id' => classmate.id.to_s, 'name' => '同じスクールの受講生', 'followedByCurrentUser' => true, 'isCurrentUser' => false }
      ]
    end
  end

  describe 'GET /api/v1/users/:id' do
    it '未ログインなら 401 を返す' do
      get "/api/v1/users/#{classmate.id}"

      expect(response).to have_http_status(:unauthorized)
    end

    it '人数とフォロー状態を返し、メールアドレスは出さない' do
      current_user.active_relationships.create!(followed: classmate)
      classmate.active_relationships.create!(followed: create(:user, tenant: tenant))

      get "/api/v1/users/#{classmate.id}", headers: user_auth_headers(current_user)

      expect(response_json['user']).to eq(
        'id'                    => classmate.id.to_s,
        'name'                  => '同じスクールの受講生',
        'followingsCount'       => 1,
        'followersCount'        => 1,
        'followedByCurrentUser' => true,
        'isCurrentUser'         => false
      )
    end

    it '解約した受講生は人数に数えない' do
      cancelled_follower = create(:user, tenant: tenant)
      cancelled_follower.active_relationships.create!(followed: classmate)
      cancelled_follower.update!(cancelled_at: Time.current)
      current_user.active_relationships.create!(followed: classmate)

      get "/api/v1/users/#{classmate.id}", headers: user_auth_headers(current_user)

      expect(response_json['user']['followersCount']).to eq 1
    end

    it '他のスクールの受講生なら 404 を返す' do
      get "/api/v1/users/#{create(:user, tenant: create(:tenant)).id}", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
    end

    it '解約した受講生なら 404 を返す' do
      cancelled_user = create(:user, tenant: tenant, cancelled_at: Time.current)

      get "/api/v1/users/#{cancelled_user.id}", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
    end

    it '存在しない ID なら 404 を返す' do
      get '/api/v1/users/0', headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/users/:id/followings' do
    it '未ログインなら 401 を返す' do
      get "/api/v1/users/#{classmate.id}/followings"

      expect(response).to have_http_status(:unauthorized)
    end

    it 'フォローしている人を新しい順に返し、解約した人は出さない' do
      older_followed = create(:user, tenant: tenant, name: '前にフォローした人')
      newer_followed = create(:user, tenant: tenant, name: '後でフォローした人')
      cancelled_followed = create(:user, tenant: tenant)
      classmate.active_relationships.create!(followed: older_followed, created_at: 2.days.ago)
      classmate.active_relationships.create!(followed: newer_followed, created_at: 1.day.ago)
      classmate.active_relationships.create!(followed: cancelled_followed)
      cancelled_followed.update!(cancelled_at: Time.current)
      current_user.active_relationships.create!(followed: newer_followed)

      get "/api/v1/users/#{classmate.id}/followings", headers: user_auth_headers(current_user)

      expect(response_json['users']).to eq [
        { 'id' => newer_followed.id.to_s, 'name' => '後でフォローした人', 'followedByCurrentUser' => true, 'isCurrentUser' => false },
        { 'id' => older_followed.id.to_s, 'name' => '前にフォローした人', 'followedByCurrentUser' => false, 'isCurrentUser' => false }
      ]
    end

    it '他のスクールの受講生なら 404 を返す' do
      get "/api/v1/users/#{create(:user, tenant: create(:tenant)).id}/followings", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'GET /api/v1/users/:id/followers' do
    it '未ログインなら 401 を返す' do
      get "/api/v1/users/#{classmate.id}/followers"

      expect(response).to have_http_status(:unauthorized)
    end

    it 'フォロワーを新しい順に返し、行数は受講生情報の followersCount と一致する' do
      older_follower = create(:user, tenant: tenant, name: '前からのフォロワー')
      cancelled_follower = create(:user, tenant: tenant)
      older_follower.active_relationships.create!(followed: classmate, created_at: 1.day.ago)
      cancelled_follower.active_relationships.create!(followed: classmate)
      cancelled_follower.update!(cancelled_at: Time.current)
      current_user.active_relationships.create!(followed: classmate)

      get "/api/v1/users/#{classmate.id}/followers", headers: user_auth_headers(current_user)

      expect(response_json['users']).to eq [
        { 'id' => current_user.id.to_s, 'name' => '自分', 'followedByCurrentUser' => false, 'isCurrentUser' => true },
        { 'id' => older_follower.id.to_s, 'name' => '前からのフォロワー', 'followedByCurrentUser' => false, 'isCurrentUser' => false }
      ]

      get "/api/v1/users/#{classmate.id}", headers: user_auth_headers(current_user)

      expect(response_json['user']['followersCount']).to eq 2
    end

    it '解約した受講生なら 404 を返す' do
      classmate.update!(cancelled_at: Time.current)

      get "/api/v1/users/#{classmate.id}/followers", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
    end
  end
end
