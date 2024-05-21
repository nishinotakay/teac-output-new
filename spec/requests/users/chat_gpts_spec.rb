require 'rails_helper'

RSpec.describe 'Users::ChatGpts' do
  let(:user) { create(:user) }
  let(:another_user) { create(:user, email: 'another_user@example.com') }
  let!(:chat_gpt) { create(:chat_gpt, user: user, prompt: '質問内容', mode: 'teacher') }

  before(:each) do
    user.confirm
    sign_in user
    allow(OpenAiService).to receive(:generate_chat).and_return('モックされたAIレスポンス')
  end

  describe 'GET /index' do
    context '正常系' do
      it '質問一覧ページにアクセスでき、成功する(HTTP 200)' do
        get users_chat_gpts_path
        expect(response).to have_http_status(:success) # HTTPステータス200を期待
      end
    end

    context '異常系' do
      it 'ログインしていない場合、ログイン画面にリダイレクトされる(HTTP 302)' do
        sign_out user
        get users_chat_gpts_path
        expect(response).to redirect_to(new_user_session_path) # ログイン画面へのリダイレクトを期待
        expect(response).to have_http_status(:found) # HTTPステータスコード302を期待
      end
    end
  end

  describe 'GET /new' do
    context '正常系' do
      it '質問新規作成ページにアクセスでき、成功する(HTTP 200)' do
        get new_users_chat_gpt_path
        expect(response).to have_http_status(:success) # HTTPステータス200を期待
      end
    end

    context '異常系' do
      it 'ログインしていない場合、ログイン画面にリダイレクトされる(HTTP 302)' do
        sign_out user
        get new_users_chat_gpt_path
        expect(response).to redirect_to(new_user_session_path) # ログイン画面へのリダイレクトを期待
        expect(response).to have_http_status(:found) # HTTPステータスコード302を期待
      end
    end
  end

  describe 'POST /create' do
    context '正常系' do
      it '質問が正常に作成され、詳細ページにリダイレクトされる(HTTP 302)' do
        chat_gpt_params = { chat_gpt: { prompt: '質問内容', mode: 'teacher' } }
        post users_chat_gpts_path, params: chat_gpt_params
        expect(response).to redirect_to(users_chat_gpt_path(ChatGpt.last)) # 作成したチャットGPTの詳細ページへのリダイレクトを期待
        expect(OpenAiService).to have_received(:generate_chat).with('質問内容', mode: 'teacher')
      end
    end

    context '異常系' do
      it 'ログインしていない場合、ログイン画面にリダイレクトされる(HTTP 302)' do
        sign_out user
        chat_gpt_params = { chat_gpt: { prompt: '質問内容', mode: 'teacher' } }
        post users_chat_gpts_path, params: chat_gpt_params
        expect(response).to redirect_to(new_user_session_path) # ログイン画面へのリダイレクトを期待
        expect(response).to have_http_status(:found) # HTTPステータスコード302を期待
      end

      it 'バリデーションに失敗した場合、エラーメッセージが表示される(HTTP 422)' do
        chat_gpt_params = { chat_gpt: { prompt: '', mode: '' } } # バリデーションに引っかかる
        post users_chat_gpts_path, params: chat_gpt_params
        expect(response).to have_http_status(:unprocessable_entity) # HTTPステータス422を期待
      end

      it 'AIコンテンツの生成に失敗した場合、500エラーが表示される(HTTP 500)' do
        allow(OpenAiService).to receive(:generate_chat).and_raise(StandardError) # OpenAIサービスの呼び出しをエラーに設定
        user.confirm
        sign_in user
        post users_chat_gpts_path, params: { chat_gpt: { prompt: '質問内容', mode: 'teacher' } } # 質問を作成
        expect(response.body).to include('AIによるコンテンツ生成に失敗しました。') # エラーメッセージが表示されることを期待
      end
    end
  end

  describe 'GET /show' do
    context '正常系' do
      it '質問詳細ページにアクセスでき、成功する(HTTP 200)' do
        get users_chat_gpt_path(chat_gpt)
        expect(response).to have_http_status(:success) # HTTPステータス200を期待
      end
    end

    context '異常系' do
      it '他のユーザーが作成したチャットGPTにアクセスしようとすると失敗する(HTTP 404)' do
        sign_out user
        another_user.confirm
        sign_in another_user
        get users_chat_gpt_path(chat_gpt)
        expect(response).to redirect_to(users_chat_gpts_path) # アクセス拒否のため一覧ページへのリダイレクトを期待
        expect(response).to have_http_status(:found) # HTTPステータスコード302を期待
        expect(flash[:alert]).to eq('アクセス権限がありません。')
      end

      it 'ログインしていない場合、ログイン画面にリダイレクトされる(HTTP 302)' do
        sign_out user
        get users_chat_gpt_path(chat_gpt)
        expect(response).to redirect_to(new_user_session_path) # ログイン画面へのリダイレクトを期待
        expect(response).to have_http_status(:found) # HTTPステータスコード302を期待
      end
    end

    describe 'DELETE /destroy' do
      let!(:chat_gpt) { create(:chat_gpt, user: user, prompt: '質問内容', mode: 'teacher') }

      context '正常系' do
        it '自分の質問を削除できる(HTTP 302)' do
          expect {
            delete users_chat_gpt_path(chat_gpt)
          }.to change(ChatGpt, :count).by(-1)
          expect(response).to have_http_status(:found) # HTTPステータスコード302を期待
          expect(response).to redirect_to(users_chat_gpts_path)
          expect(flash[:notice]).to eq '質問が削除されました。'
        end
      end

      context '異常系' do
        it '他のユーザーの質問を削除しようとすると失敗する(HTTP 302)' do
          another_user.confirm
          sign_in another_user
          expect {
            delete users_chat_gpt_path(chat_gpt)
          }.not_to change(ChatGpt, :count)
          expect(response).to have_http_status(:found) # HTTPステータスコード302を期待
          expect(response).to redirect_to(users_chat_gpts_path)
          expect(flash[:alert]).to eq 'アクセス権限がありません。'
        end
      end
    end
  end
end
