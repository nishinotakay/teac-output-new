require 'rails_helper'

RSpec.describe "Users::Tweets", type: :request do
  let(:user) { create :user, confirmed_at: Time.new(2024,1,1,0,0,0) }
  let(:tweet) { create :tweet, user: user }
  let(:valid_params) {{ tweet: FactoryBot.attributes_for(:tweet, :valid)}}
  let(:invalid_params) {{ tweet: FactoryBot.attributes_for(:tweet, :invalid) }}
  let(:nil_params) {{ tweet: FactoryBot.attributes_for(:tweet, :nil_params)}}
  let(:referrer_url) { users_tweets_path }
  let(:another_user) { create :user, confirmed_at: Time.new(2024,1,1,0,0,0) }
  let(:another_user_tweet) { create :tweet, user: another_user }

  describe "GET /index" do
    subject { get users_tweets_path }

    # 正常系: 有効なアクセス
    context 'ログインユーザーが一覧画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'HTTPステータスコード200が返される' do
        subject
        expect(response).to have_http_status(200)
      end
    end

    # 異常系: 不正なアクセス
    context 'ログインしていないユーザーが一覧画面にアクセスした場合' do
      before do
        sign_out user
      end

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'エラーメッセージが表示される「ログインもしくはアカウント登録してください。」' do
        subject
        follow_redirect!
        expect(response.body).to include("ログインもしくはアカウント登録してください。")
      end
    end
  end

  describe "GET /show" do
    subject { get users_tweet_path(tweet.id) }

    # 正常系:有効なアクセス
    context 'ログインユーザーが詳細画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'HTTPステータスコード200が返される' do
        subject
        expect(response).to have_http_status(200)
      end
    end

    # 異常系:不正なアクセス
    context 'ログインしていないユーザーが詳細画面にアクセスした場合' do
      before do
        sign_out user
      end

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST / create" do
    before do
      sign_in user
    end
    
    # 正常系: 有効なパラメーターで投稿
    context 'ログインユーザーが新規投稿をした場合' do
      subject { post users_tweets_path, params: valid_params, headers: { "HTTP_REFERER" => referrer_url } }

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(referrer_url)
      end

      it 'つぶやきがデータベースに保存される' do
        expect { subject }.to change(Tweet, :count).by(1)
      end

      it 'メッセージ「つぶやきを作成しました。」が表示される' do
        subject
        follow_redirect!
        expect(response.body).to include("つぶやきを作成しました。")
      end
    end

    # 異常系: 無効なパラメーターで投稿
    context '空文字で新規投稿をした場合' do
      subject { post users_tweets_path, params: nil_params, headers: { "HTTP_REFERER" => referrer_url } }

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(referrer_url)
      end

      it 'エラーメッセージ「投稿内容を入力してください」が表示される' do
        subject
        follow_redirect!
        expect(response.body).to include("投稿内容を入力してください")
      end
    end

    # 異常系: 無効なパラメーターで投稿
    context '255文字以上の新規投稿をした場合' do
      subject { post users_tweets_path, params: invalid_params, headers: { "HTTP_REFERER" => referrer_url } }

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(referrer_url)
      end

      it 'エラーメッセージ「投稿内容は255文字以内で入力してください」が表示される。' do
        subject
        follow_redirect!
        expect(response.body).to include("投稿内容は255文字以内で入力してください")
      end
    end
  end

  describe "GET / edit" do

    # 正常系: 有効な操作
    context 'ログインユーザーが編集画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'HTTPステータスコード200が返される' do
        get edit_users_tweet_path(tweet.id), xhr: true
        expect(response).to have_http_status(200)
      end
    end

    # 異常系: 不正な操作
    context 'ログインしていないユーザーが編集画面にアクセスした場合' do
      subject { get edit_users_tweet_path(tweet.id) }

      before do
        sign_out user
      end

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'エラーメッセージ「ログインもしくはアカウント登録してください。」が表示される' do
        subject
        follow_redirect!
        expect(response.body).to include("ログインもしくはアカウント登録してください。")
      end
    end

    # 異常系: 不正な操作
    context 'ログインユーザーが他のユーザーの編集画面にアクセスした場合' do
      subject { get edit_users_tweet_path(another_user_tweet.id) }

      before do
        sign_in user
      end

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(users_dash_boards_path)
      end

      it 'エラーメッセージ「ログインもしくはアカウント登録してください。」が表示される' do
        subject
        follow_redirect!
        expect(response.body).to include("アクセスできません")
      end
    end
  end

  describe "PATCH / update" do
    before do
      sign_in user
    end

    # 正常系: 有効なパラメーターで更新
    context "ログインユーザーがつぶやきを更新した場合" do
      it 'HTTPステータスコード302が表示される' do
        patch users_tweet_path(tweet.id), params: valid_params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(users_tweets_url)
      end

      it 'メッセージ「編集成功しました。」が表示される' do
        patch users_tweet_path(tweet.id), params: valid_params
        follow_redirect!
        expect(response.body).to include("編集成功しました。")
      end

      it 'つぶやきが更新される(更新時に入力した文字列がデータベースに反映される)' do
        new_post = "Update test tweet"
        patch users_tweet_path(tweet.id), params: { tweet: { post: new_post} }
        expect(tweet.reload.post).to eq(new_post)
      end
    end

    # 異常系: 無効なパラメーターで更新
    context "空文字でつぶやきを更新した場合" do
      subject { patch users_tweet_path(tweet.id), params: nil_params, xhr: true }

      it "HTTPステータスコード200が返される" do
        subject
        expect(response).to have_http_status(200)
      end

      it "エラーメッセージ「投稿内容を入力してください」が表示される" do
        subject
        expect(response.body).to include("投稿内容を入力してください")
      end
    end

    # 異常系: 無効なパラメーターで更新
    context "255文字以上でつぶやきを更新した場合" do
      subject { patch users_tweet_path(tweet.id), params: invalid_params, xhr: true }

      it "HTTPステータスコード200が返される" do
        subject
        expect(response).to have_http_status(200)
      end

      it "エラーメッセージ「投稿内容は255文字以内で入力してください」が表示される" do
        subject
        expect(response.body).to include("投稿内容は255文字以内で入力してください")
      end
    end
  end

  describe "DELETE / destroy" do
    before do
      sign_in user
      @tweet = FactoryBot.create(:tweet, user: user)
    end

    # 正常系: 有効な操作
    context 'ログインユーザーがつぶやきを削除した場合' do
      subject { delete users_tweet_path(@tweet.id) }

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to users_tweets_url
      end

      it 'メッセージ「削除に成功しました。」が表示される' do
        subject
        follow_redirect!
        expect(response.body).to include("削除に成功しました。")
      end

      it 'つぶやきが削除される(データベースからつぶやきが１つ減る)' do
        expect { subject }.to change(Tweet, :count).by(-1)
      end
    end

    # 異常系: 不正な操作
    context "ログインユーザーが別のユーザーの投稿を削除する操作をした場合" do
      subject { delete users_tweet_path(another_user_tweet.id) }

      it "HTTPステータスコード302が返される" do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(users_dash_boards_path)
      end

      it "エラーメッセージ「アクセスできません」が表示される" do
        subject
        follow_redirect!
        expect(response.body).to include("アクセスできません")
      end
    end
  end

  describe "index_user" do
    subject { get index_user_users_tweet_path(user.id)}

    # 正常系: 有効なアクセス
    context 'ログインユーザーが個別のユーザーの一覧画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'HTTPステータスコード200が返される' do
        subject
        expect(response).to have_http_status(200)
      end
    end

    # 異常系: 不正なアクセス
    context 'ログインしていないユーザーが個別のユーザーの一覧画面にアクセスした場合' do
      before do
        sign_out user
      end

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "エラーメッセージ「ログインもしくはアカウント登録してください。」が表示される" do
        subject
        follow_redirect!
        expect(response.body).to include("ログインもしくはアカウント登録してください。")
      end
    end
  end
end

