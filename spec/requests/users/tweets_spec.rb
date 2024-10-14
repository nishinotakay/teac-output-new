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

    context 'ログインユーザーが一覧画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'HTTPステータスコード200が返される' do
        subject
        expect(response).to have_http_status(200)
      end
    end

    context 'ログインしていないユーザーが一覧画面にアクセスした場合' do
      before do
        sign_out user
      end

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'エラーメッセージが存在する' do
        subject
        follow_redirect!
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "GET /show" do
    subject { get users_tweet_path(tweet.id) }

    context 'ログインユーザーが詳細画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'HTTPステータスコード200が返される' do
        subject
        expect(response).to have_http_status(200)
      end
    end

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

      it 'サクセスメッセージが存在する' do
        subject
        follow_redirect!
        expect(flash[:success]).to be_present
      end
    end

    context '空文字で新規投稿をした場合' do
      subject { post users_tweets_path, params: nil_params, headers: { "HTTP_REFERER" => referrer_url } }

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(referrer_url)
      end

      it 'エラーメッセージが存在する' do
        subject
        follow_redirect!
        expect(flash[:error]).to be_present
      end
    end

    context '255文字以上の新規投稿をした場合' do
      subject { post users_tweets_path, params: invalid_params, headers: { "HTTP_REFERER" => referrer_url } }

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(referrer_url)
      end

      it 'エラーメッセージが存在する' do
        subject
        follow_redirect!
        expect(flash[:error]).to be_present
      end
    end
  end

  describe "GET / edit" do

    context 'ログインユーザーが編集画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'HTTPステータスコード200が返される' do
        get edit_users_tweet_path(tweet.id), xhr: true
        expect(response).to have_http_status(200)
      end
    end

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

      it 'エラーメッセージが存在する' do
        subject
        follow_redirect!
        expect(flash[:alert]).to be_present
      end
    end

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

      it 'エラーメッセージが存在する' do
        subject
        follow_redirect!
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "PATCH / update" do
    before do
      sign_in user
    end

    context "ログインユーザーがつぶやきを更新した場合" do
      it 'HTTPステータスコード302が返される' do
        patch users_tweet_path(tweet.id), params: valid_params
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(users_tweets_url)
      end

      it 'サクセスメッセージが存在する' do
        patch users_tweet_path(tweet.id), params: valid_params
        follow_redirect!
        expect(flash[:success]).to be_present
      end

      it 'つぶやきが更新される' do
        new_post = "Update test tweet"
        patch users_tweet_path(tweet.id), params: { tweet: { post: new_post} }
        expect(tweet.reload.post).to eq(new_post)
      end
    end

    context "空文字でつぶやきを更新した場合" do  
      it "HTTPステータスコード200が返される" do
        patch users_tweet_path(tweet.id), params: nil_params, xhr: true
        expect(response).to have_http_status(200)
      end
    end

    context "255文字以上でつぶやきを更新した場合" do
      it "HTTPステータスコード200が返される" do
        patch users_tweet_path(tweet.id), params: invalid_params, xhr: true
        expect(response).to have_http_status(200)
      end 
    end
  end

  describe "DELETE / destroy" do
    before do
      sign_in user
      @tweet = FactoryBot.create(:tweet, user: user)
    end

    context 'ログインユーザーがつぶやきを削除した場合' do
      subject { delete users_tweet_path(@tweet.id) }

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to users_tweets_url
      end

      it 'サクセスメッセージが存在する' do
        subject
        follow_redirect!
        expect(flash[:success]).to be_present
      end

      it 'つぶやきが削除される' do
        expect { subject }.to change(Tweet, :count).by(-1)
      end
    end

    context "ログインユーザーが別のユーザーの投稿を削除する操作をした場合" do
      subject { delete users_tweet_path(another_user_tweet.id) }

      it "HTTPステータスコード302が返される" do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(users_dash_boards_path)
      end

      it "エラーメッセージが存在する" do
        subject
        follow_redirect!
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe "index_user" do
    subject { get index_user_users_tweet_path(user.id)}

    context 'ログインユーザーが個別のユーザーの一覧画面にアクセスした場合' do
      before do
        sign_in user
      end

      it 'HTTPステータスコード200が返される' do
        subject
        expect(response).to have_http_status(200)
      end
    end

    context 'ログインしていないユーザーが個別のユーザーの一覧画面にアクセスした場合' do
      before do
        sign_out user
      end

      it 'HTTPステータスコード302が返される' do
        subject
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end

      it "エラーメッセージが存在する" do
        subject
        follow_redirect!
        expect(flash[:alert]).to be_present
      end
    end
  end
end

