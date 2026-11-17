# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users::Relationships' do
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
  let(:current_user) { create(:user, tenant: tenant) }
  let(:classmate) { create(:user, tenant: tenant) }
  let(:other_tenant_user) { create(:user, tenant: create(:tenant)) }

  describe 'POST /api/v1/users/:user_id/follow' do
    it '未ログインなら 401 を返し、フォローしない' do
      expect { post "/api/v1/users/#{classmate.id}/follow" }.not_to change(Relationship, :count)
      expect(response).to have_http_status(:unauthorized)
    end

    it '講師のトークンなら 401 を返し、フォローしない' do
      admin = create(:admin, tenant: tenant)

      expect { post "/api/v1/users/#{classmate.id}/follow", headers: admin_auth_headers(admin) }.not_to change(Relationship, :count)
      expect(response).to have_http_status(:unauthorized)
    end

    it '同じスクールの受講生をフォローし、201 と相手の最新の人数を返す' do
      post "/api/v1/users/#{classmate.id}/follow", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:created)
      expect(current_user.followings).to contain_exactly(classmate)
      expect(response_json['user']).to include('id' => classmate.id.to_s, 'followersCount' => 1, 'followedByCurrentUser' => true)
    end

    it 'すでにフォローしている相手なら 422 を返し、件数を変えない' do
      current_user.active_relationships.create!(followed: classmate)

      expect { post "/api/v1/users/#{classmate.id}/follow", headers: user_auth_headers(current_user) }.not_to change(Relationship, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json['errors']).to eq ['すでにフォローしています']
    end

    it '同時に 2 回押されて DB の一意制約で止まっても、500 にせず 422 を返す' do
      current_user.active_relationships.create!(followed: classmate)
      # バリデーションを素通りさせ、DB の一意制約だけで止まる状況を作る
      allow_any_instance_of(Relationship).to receive(:not_already_following)

      expect { post "/api/v1/users/#{classmate.id}/follow", headers: user_auth_headers(current_user) }.not_to change(Relationship, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json['errors']).to eq ['すでにフォローしています']
    end

    it '自分自身なら 422 を返し、件数を変えない' do
      expect { post "/api/v1/users/#{current_user.id}/follow", headers: user_auth_headers(current_user) }.not_to change(Relationship, :count)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json['errors']).to eq ['自分自身はフォローできません']
    end

    it '他のスクールの受講生なら 404 を返し、件数を変えない' do
      expect { post "/api/v1/users/#{other_tenant_user.id}/follow", headers: user_auth_headers(current_user) }.not_to change(Relationship, :count)
      expect(response).to have_http_status(:not_found)
    end

    it '解約した受講生なら 404 を返し、件数を変えない' do
      classmate.update!(cancelled_at: Time.current)

      expect { post "/api/v1/users/#{classmate.id}/follow", headers: user_auth_headers(current_user) }.not_to change(Relationship, :count)
      expect(response).to have_http_status(:not_found)
    end

    it '存在しない ID なら 404 を返す' do
      post '/api/v1/users/0/follow', headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/users/:user_id/follow' do
    it '未ログインなら 401 を返し、外さない' do
      current_user.active_relationships.create!(followed: classmate)

      expect { delete "/api/v1/users/#{classmate.id}/follow" }.not_to change(Relationship, :count)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'フォローを外し、200 と相手の最新の人数を返す' do
      current_user.active_relationships.create!(followed: classmate)

      delete "/api/v1/users/#{classmate.id}/follow", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(current_user.followings).to be_empty
      expect(response_json['user']).to include('id' => classmate.id.to_s, 'followersCount' => 0, 'followedByCurrentUser' => false)
    end

    it '自分のフォローだけを外し、他の受講生のフォローは残す' do
      current_user.active_relationships.create!(followed: classmate)
      other_follower = create(:user, tenant: tenant)
      other_follower.active_relationships.create!(followed: classmate)

      delete "/api/v1/users/#{classmate.id}/follow", headers: user_auth_headers(current_user)

      expect(classmate.followers).to contain_exactly(other_follower)
    end

    it 'フォローしていない相手なら 404 を返し、件数を変えない' do
      create(:user, tenant: tenant).active_relationships.create!(followed: classmate)

      expect { delete "/api/v1/users/#{classmate.id}/follow", headers: user_auth_headers(current_user) }.not_to change(Relationship, :count)
      expect(response).to have_http_status(:not_found)
    end

    it '他のスクールの受講生なら 404 を返し、件数を変えない' do
      create(:relationship, followed: other_tenant_user, follower: create(:user, tenant: other_tenant_user.tenant))

      expect { delete "/api/v1/users/#{other_tenant_user.id}/follow", headers: user_auth_headers(current_user) }.not_to change(Relationship, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
