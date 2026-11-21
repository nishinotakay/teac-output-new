# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Users::ChatMessages' do
  def user_auth_headers(user)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" }
  end

  def response_json
    JSON.parse(response.body)
  end

  let(:tenant) { create(:tenant) }
  let(:current_user) { create(:user, tenant: tenant) }
  let(:classmate) { create(:user, tenant: tenant, name: '佐藤花子') }
  let(:chat_room) { ChatRoom.find_or_create_between!(current_user, classmate) }
  let(:outsider) { create(:user, tenant: tenant) }
  let(:other_tenant_room) { create(:chat_message).chat_room }

  describe 'GET /api/v1/chat_rooms/:chat_room_id/messages' do
    it '未ログインなら 401 を返す' do
      get "/api/v1/chat_rooms/#{chat_room.id}/messages"

      expect(response).to have_http_status(:unauthorized)
    end

    it '参加している部屋のメッセージを古い順に返し、自分の発言に isMine を付ける' do
      first_message = create(:chat_message, chat_room: chat_room, user: current_user, created_at: 1.hour.ago)
      second_message = create(:chat_message, chat_room: chat_room, user: classmate, created_at: 1.minute.ago)

      get "/api/v1/chat_rooms/#{chat_room.id}/messages", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:ok)
      expect(response_json['chatRoom']).to eq('id' => chat_room.id.to_s, 'partner' => { 'id' => classmate.id.to_s, 'name' => '佐藤花子' })
      expect(response_json['chatMessages'].map { |message| message.slice('id', 'userId', 'isMine') }).to eq [
        { 'id' => first_message.id.to_s, 'userId' => current_user.id.to_s, 'isMine' => true },
        { 'id' => second_message.id.to_s, 'userId' => classmate.id.to_s, 'isMine' => false }
      ]
    end

    it 'after_id を付けると、それより新しいメッセージだけを返す' do
      first_message = create(:chat_message, chat_room: chat_room, user: current_user)
      second_message = create(:chat_message, chat_room: chat_room, user: classmate)

      get "/api/v1/chat_rooms/#{chat_room.id}/messages", params: { after_id: first_message.id }, headers: user_auth_headers(current_user)

      expect(response_json['chatMessages'].pluck('id')).to eq [second_message.id.to_s]
    end

    it '参加していない部屋なら 404 を返す' do
      get "/api/v1/chat_rooms/#{chat_room.id}/messages", headers: user_auth_headers(outsider)

      expect(response).to have_http_status(:not_found)
    end

    it '別のスクールの部屋なら 404 を返す' do
      get "/api/v1/chat_rooms/#{other_tenant_room.id}/messages", headers: user_auth_headers(current_user)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/v1/chat_rooms/:chat_room_id/messages' do
    it '未ログインなら 401 を返し、送らない' do
      expect { post "/api/v1/chat_rooms/#{chat_room.id}/messages", params: { content: 'こんにちは' } }.not_to change(ChatMessage, :count)
      expect(response).to have_http_status(:unauthorized)
    end

    it '参加している部屋に、ログイン中の本人の発言として保存し 201 を返す' do
      expect {
        post "/api/v1/chat_rooms/#{chat_room.id}/messages", params: { content: 'こんにちは', user_id: classmate.id }, headers: user_auth_headers(current_user)
      }.to change(ChatMessage, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(ChatMessage.last.user).to eq current_user
      expect(response_json['chatMessage']).to include('content' => 'こんにちは', 'userId' => current_user.id.to_s, 'isMine' => true)
    end

    it '本文が空なら 422 を返し、保存しない' do
      expect { post "/api/v1/chat_rooms/#{chat_room.id}/messages", params: { content: '' }, headers: user_auth_headers(current_user) }.not_to change(ChatMessage, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it '本文が 1000 文字なら保存し、1001 文字なら 422 を返す' do
      post "/api/v1/chat_rooms/#{chat_room.id}/messages", params: { content: 'あ' * 1000 }, headers: user_auth_headers(current_user)
      expect(response).to have_http_status(:created)

      expect { post "/api/v1/chat_rooms/#{chat_room.id}/messages", params: { content: 'あ' * 1001 }, headers: user_auth_headers(current_user) }.not_to change(ChatMessage, :count)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it '参加していない部屋なら 404 を返し、保存しない' do
      chat_room
      expect { post "/api/v1/chat_rooms/#{chat_room.id}/messages", params: { content: 'のぞき' }, headers: user_auth_headers(outsider) }.not_to change(ChatMessage, :count)
      expect(response).to have_http_status(:not_found)
    end
  end
end
