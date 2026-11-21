# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users::ChatRooms' do
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
  let(:classmate) { create(:user, tenant: tenant, name: '佐藤花子') }
  let(:other_tenant_user) { create(:user, tenant: create(:tenant)) }

  describe 'GET /api/v1/chat_rooms' do
    it '未ログインなら 401 を返す' do
      get '/api/v1/chat_rooms'

      expect(response).to have_http_status(:unauthorized)
    end

    it '自分が参加している部屋だけを、最後のメッセージの新しい順で返す' do
      first_created_room = ChatRoom.find_or_create_between!(current_user, classmate)
      second_created_room = ChatRoom.find_or_create_between!(current_user, create(:user, tenant: tenant))
      create(:chat_message, chat_room: first_created_room, user: classmate, created_at: 1.hour.ago)
      create(:chat_message, chat_room: second_created_room, user: current_user, created_at: 2.days.ago)
      ChatRoom.find_or_create_between!(classmate, create(:user, tenant: tenant))

      get '/api/v1/chat_rooms', headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(response_json['chatRooms'].pluck('id')).to eq [first_created_room.id.to_s, second_created_room.id.to_s]
    end

    it 'メッセージの無い部屋は、部屋の作成日時で並べ、lastMessage を null で返す' do
      chat_room = ChatRoom.find_or_create_between!(current_user, classmate)

      get '/api/v1/chat_rooms', headers: user_auth_headers(current_user)

      expect(response_json['chatRooms']).to eq [{
        'id'          => chat_room.id.to_s,
        'partner'     => { 'id' => classmate.id.to_s, 'name' => '佐藤花子' },
        'lastMessage' => nil,
        'createdAt'   => chat_room.created_at.iso8601
      }]
    end
  end

  describe 'POST /api/v1/chat_rooms' do
    before(:each) { current_user.active_relationships.create!(followed: classmate) }

    it '未ログインなら 401 を返し、部屋を作らない' do
      expect { post '/api/v1/chat_rooms', params: { user_id: classmate.id } }.not_to change(ChatRoom, :count)
      expect(response).to have_http_status(:unauthorized)
    end

    it '講師のトークンなら 401 を返し、部屋を作らない' do
      admin = create(:admin, tenant: tenant)

      expect { post '/api/v1/chat_rooms', params: { user_id: classmate.id }, headers: admin_auth_headers(admin) }.not_to change(ChatRoom, :count)
      expect(response).to have_http_status(:unauthorized)
    end

    it 'フォローしている相手なら部屋と参加者 2 人を作り、201 を返す' do
      expect { post '/api/v1/chat_rooms', params: { user_id: classmate.id }, headers: user_auth_headers(current_user) }
        .to change(ChatRoom, :count).by(1).and change(ChatRoomUser, :count).by(2)
      expect(response).to have_http_status(:created)
      expect(response_json['chatRoom']).to include('partner' => { 'id' => classmate.id.to_s, 'name' => '佐藤花子' }, 'lastMessage' => nil)
      expect(ChatRoom.last.tenant).to eq tenant
    end

    it '2 人の部屋がすでにあれば、作らずに同じ部屋を 200 で返す' do
      chat_room = ChatRoom.find_or_create_between!(classmate, current_user)

      expect { post '/api/v1/chat_rooms', params: { user_id: classmate.id }, headers: user_auth_headers(current_user) }.not_to change(ChatRoom, :count)
      expect(response).to have_http_status(:ok)
      expect(response_json['chatRoom']['id']).to eq chat_room.id.to_s
    end

    it 'フォローしていない相手なら 404 を返し、部屋を作らない' do
      stranger = create(:user, tenant: tenant)

      expect { post '/api/v1/chat_rooms', params: { user_id: stranger.id }, headers: user_auth_headers(current_user) }.not_to change(ChatRoom, :count)
      expect(response).to have_http_status(:not_found)
    end

    it '自分自身を指定したら 422 を返し、部屋を作らない' do
      expect { post '/api/v1/chat_rooms', params: { user_id: current_user.id }, headers: user_auth_headers(current_user) }.not_to change(ChatRoom, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it '別のスクールの受講生なら 404 を返し、部屋を作らない' do
      expect { post '/api/v1/chat_rooms', params: { user_id: other_tenant_user.id }, headers: user_auth_headers(current_user) }.not_to change(ChatRoom, :count)
      expect(response).to have_http_status(:not_found)
    end

    it '解約済みの受講生なら 404 を返し、部屋を作らない' do
      classmate.update_column(:cancelled_at, Time.current)

      expect { post '/api/v1/chat_rooms', params: { user_id: classmate.id }, headers: user_auth_headers(current_user) }.not_to change(ChatRoom, :count)
      expect(response).to have_http_status(:not_found)
    end

    it '存在しない ID なら 404 を返す' do
      post '/api/v1/chat_rooms', params: { user_id: 0 }, headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
    end
  end
end
