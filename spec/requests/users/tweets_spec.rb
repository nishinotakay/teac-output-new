require 'rails_helper'

RSpec.describe "Users::Tweets", type: :request do
  let(:user) { FactoryBot.create(:user, confirmed_at: Time.now) }
  let(:tweet) { FactoryBot.create(:tweet, user: user) }
  let(:valid_params) {{ tweet: FactoryBot.attributes_for(:tweet, :valid)}}
  let(:invalid_params) {{ tweet: FactoryBot.attributes_for(:tweet, :invalid) }}
  let(:nil_params) {{ tweet: FactoryBot.attributes_for(:tweet, :nil_params)}}
  let(:referrer_url) { users_tweets_path }
  let(:another_user) { FactoryBot.create(:user, confirmed_at: Time.now )}
  let(:another_user_tweet) { FactoryBot.create(:tweet, user: another_user)}

  describe "GET /index" do
    context 'ログインしているユーザーがつぶやき一覧にアクセスした場合' do
      before do
        sign_in user
      end

      it 'つぶやき一覧が表示される(HTTPステータスコード200が返される)' do
        get users_tweets_path
        expect(response).to have_http_status(200)
      end
    end

    context 'ログインしていないユーザーがつぶやき一覧にアクセスした場合' do
      before do
        sign_out user
      end

      it 'ログインページにリダイレクトされる(HTTPステータスコード302が返される)' do
        get users_tweets_path
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'エラーメッセージが表示される「ログインもしくはアカウント登録してください。」' do
        get users_tweets_path
        follow_redirect!
        expect(response.body).to include("ログインもしくはアカウント登録してください。")
      end
    end
  end

  describe "GET /show" do
    context 'ログインしているユーザーがつぶやき詳細画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'つぶやき詳細画面が表示される(HTTPステータスコード200が返される)' do
        get users_tweet_path(tweet.id)
        expect(response).to have_http_status(200)
      end
    end

    context 'ログインしていないユーザーがつぶやき詳細画面にアクセスした場合' do
      before do
        sign_out user
      end

      it 'ログインページにリダイレクトされる(HTTPステータスコード302が返される)' do
        get users_tweet_path(tweet.id)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST / create" do
    context 'ログインしているユーザーがつぶやきを作成した場合' do
      before do
        sign_in user
      end

      it 'つぶやき一覧画面にリダイレクトされる(HTTPステータスコード302が返される)' do
        post users_tweets_path, params: valid_params, headers: { "HTTP_REFERER" => referrer_url }
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(referrer_url)
      end

      it 'つぶやきがデータベースに保存される' do
        expect { post users_tweets_path, params: valid_params }.to change(Tweet, :count).by(1)
      end

      it 'メッセージ「つぶやきを作成しました。」が表示される ' do
        post users_tweets_path, params: valid_params, headers: { "HTTP_REFERER" => referrer_url }
        follow_redirect!
        expect(response.body).to include("つぶやきを作成しました。")
      end

      context 'ログインしているユーザーが空文字でつぶやきを投稿した場合' do
        it 'つぶやき一覧画面にリダイレクトされる(HTTPステータスコード302が返される)' do
          post users_tweets_path, params: nil_params, headers: { "HTTP_REFERER" => referrer_url }
          expect(response).to have_http_status(302)
          expect(response).to redirect_to(referrer_url)
        end

        it 'エラーメッセージ「投稿内容を入力してください」が表示される' do
          post users_tweets_path, params: nil_params, headers: { "HTTP_REFERER" => referrer_url }
          follow_redirect!
          expect(response.body).to include("投稿内容を入力してください")
        end
      end

      context 'ログインしているユーザーが255文字以上のつぶやきを投稿した場合' do
        it 'つぶやき一覧画面にリダイレクトされる(HTTPステータスコード302が返される)' do
          post users_tweets_path, params: invalid_params, headers: { "HTTP_REFERER" => referrer_url }
          expect(response).to have_http_status(302)
          expect(response).to redirect_to(referrer_url)
        end

        it 'エラーメッセージ「投稿内容は255文字以内で入力してください」が表示される。' do
          post users_tweets_path, params: invalid_params, headers: { "HTTP_REFERER" => referrer_url }
          follow_redirect!
          expect(response.body).to include("投稿内容は255文字以内で入力してください")
        end
      end
    end
  end

  describe "GET / edit" do
    context 'ログインしているユーザーが つぶやき編集画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'つぶやき編集画面にアクセスした場合(HTTPステータスコード200が返される)' do
        get edit_users_tweet_path(tweet.id), xhr: true
        expect(response).to have_http_status(200)
      end
    end

    context 'ログインしていないユーザーがつぶやき編集画面にアクセスした場合' do
      before do
        sign_out user
      end

      it 'ログイン画面にリダイレクトされる(HTTPステータスコード302が返される)' do
        get edit_users_tweet_path(tweet.id)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'エラーメッセージ「ログインもしくはアカウント登録してください。」が表示される' do
        get edit_users_tweet_path(tweet.id)
        follow_redirect!
        expect(response.body).to include("ログインもしくはアカウント登録してください。")
      end
    end

    context 'ログインしているユーザーが他ユーザーのつぶやき編集画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'ログイン画面にリダイレクトされる(HTTPステータスコード302が返される)' do
        get edit_users_tweet_path(another_user_tweet.id)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(users_dash_boards_path)
      end

      it 'エラーメッセージ「ログインもしくはアカウント登録してください。」が表示される' do
        get edit_users_tweet_path(another_user_tweet.id)
        follow_redirect!
        expect(response.body).to include("アクセスできません")
      end
    end
  end

  describe "PATCH / update" do
    before do
      sign_in user
    end

    context "ログインしているユーザーがつぶやきを更新した場合" do
      it '記事詳細画面にリダイレクトされる(HTTPステータスコード302が表示される)' do
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

    context "ログインしているユーザーが空文字でつぶやきを更新した場合" do
      it "つぶやき編集画面から遷移しない(HTTPステータスコード200が返される)" do
        patch users_tweet_path(tweet.id), params: nil_params, xhr: true
        expect(response).to have_http_status(200)
      end

      it "エラーメッセージ「投稿内容を入力してください」が表示される" do
        patch users_tweet_path(tweet.id), params: nil_params, xhr: true
        expect(response.body).to include("投稿内容を入力してください")
      end
    end

    context "ログインしているユーザーが255文字以上でつぶやきを更新した場合" do
      it "つぶやき編集画面から遷移しない(HTTPステータスコード200が返される)" do
        patch users_tweet_path(tweet.id), params: invalid_params, xhr: true
        expect(response).to have_http_status(200)
      end

      it "エラーメッセージ「投稿内容は255文字以内で入力してください」が表示される" do
        patch users_tweet_path(tweet.id), params: invalid_params, xhr: true
        expect(response.body).to include("投稿内容は255文字以内で入力してください")
      end
    end
  end

  describe "DELETE / destroy" do
    before do
      sign_in user
      @tweet = FactoryBot.create(:tweet, user: user)
    end

    context 'ログインしているユーザーがつぶやきを削除した場合' do
      it 'つぶやき一覧画面にリダイレクトされる' do
        delete users_tweet_path(@tweet.id)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to users_tweets_url
      end

      it 'メッセージ「削除に成功しました。」が表示される' do
        delete users_tweet_path(@tweet.id)
        follow_redirect!
        expect(response.body).to include("削除に成功しました。")
      end

      it 'つぶやきが削除される(データベースからつぶやきが１つ減る)' do
        expect { delete users_tweet_path(@tweet.id) }.to change(Tweet, :count).by(-1)
      end

      context "ログインしているユーザーが別のユーザーのつぶやきを削除の操作をした場合" do
        it "ユーザーダッシュボードにリダイレクトされる(HTTPステータスコード302)" do
          delete users_tweet_path(another_user_tweet.id)
          expect(response).to have_http_status(302)
          expect(response).to redirect_to(users_dash_boards_path)
        end

        it "エラーメッセージ「アクセスできません」が表示される" do
          delete users_tweet_path(another_user_tweet.id)
          follow_redirect!
          expect(response.body).to include("アクセスできません")
        end
      end
    end
  end

  describe "index_user" do
    context 'ログインしているユーザーが個別のユーザーのつぶやき一覧画面に遷移した場合' do
      before do
        sign_in user
      end

      it '個別のユーザーのつぶやき一覧画面が表示される(HTTPステータスコード200が返される)' do
        get index_user_users_tweet_path(user.id)
        expect(response).to have_http_status(200)
      end
    end

    context 'ログインしていないユーザーが個別のユーザーのつぶやき一覧画面に遷移した場合' do
      before do
        sign_out user
      end

      it 'ログイン画面にリダイレクトされる(HTTPステータスコード302が返される)' do
        get index_user_users_tweet_path(user.id)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "エラーメッセージ「ログインもしくはアカウント登録してください。」が表示される" do
        get index_user_users_tweet_path(user.id)
        follow_redirect!
        expect(response.body).to include("ログインもしくはアカウント登録してください。")
      end
    end
  end
end

