require 'rails_helper'
describe Users::PostsController, type: :request do
  describe "コントローラーのテスト" do
    before do
      @user = FactoryBot.create(:user)
      # deviseでメール認証機能をつけている場合はサインインの前に user.confirm を行い認証を済ませておく必要がある
      @user.confirm
      @post = @user.posts.create(
        title: "Rspecコントローラーテスト",
        body: "Rspecコントローラーテストの方法を解説",
        youtube_url: "youtube.com/watch?v=qpiKb0mdbr0&t=496s"
        )
    end
    describe "アクセス権限を有するUserの場合" do
      context 'indexアクションテスト' do
        # indexページにアクセスするレスポンス
        it "indexへのアクセスに対して正常なレスポンスが返ってきているか" do
          sign_in @user
          get users_posts_path
          expect(response).to be_successful
        end

        # 200とは、成功した応答のHTTPレスポンス
        it "indexのアクセスに対して返ってきたレスポンスが200レスポンスであったか" do
          sign_in @user
          get users_posts_path
          expect(response).to have_http_status(200)
        end
      end

      context 'index_1アクションテスト' do
        # indexページにアクセスするレスポンス
        it "index_1へのアクセスに対して正常なレスポンスが返ってきているか" do
          sign_in @user
          get index_1_users_posts_path
          expect(response).to be_successful
        end

        # 200とは、成功した応答のHTTPレスポンス
        it "index_1のアクセスに対して返ってきたレスポンスが200レスポンスであったか" do
          sign_in @user
          get index_1_users_posts_path
          expect(response).to have_http_status(200)
        end
      end

      context 'showアクションテスト' do
        # showページが正常にひらけているか
        it "showへのアクセスに対して正常なレスポンスが返ってきているか？" do
          sign_in @user
          get users_post_path @post
          expect(response).to be_successful
        end

        # 200とは、成功した応答のHTTPレスポンス
        it "showのアクセスに対して返ってきたレスポンスが200レスポンスであったか" do
          sign_in @user
          get users_post_path @post
          expect(response).to have_http_status(200)
        end
      end

      context 'show_1アクションテスト' do
        # showページが正常にひらけているか
        it "show_1へのアクセスに対して正常なレスポンスが返ってきているか？" do
          sign_in @user
          get show_1_users_post_path @post
          expect(response).to be_successful
        end

        # 200とは、成功した応答のHTTPレスポンス
        it "show_1のアクセスに対して返ってきたレスポンスが200レスポンスであったか" do
          sign_in @user
          get show_1_users_post_path @post
          expect(response).to have_http_status(200)
        end
      end

      context 'newアクションテスト' do
        # newページが正常にひらけているか
        it "newへのアクセスに対して正常なレスポンスが返ってきているか？" do
          sign_in @user
          get new_users_post_path @post
          expect(response).to be_successful
        end

        # 200とは、成功した応答のHTTPレスポンス
        it "newのアクセスに対して返ってきたレスポンスが200レスポンスであったか" do
          sign_in @user
          get new_users_post_path @post
          expect(response).to have_http_status(200)
        end
      end
    end

    describe "権限を有しないゲストユーザーの場合" do
      before do
        @user = FactoryBot.create(:user)
        @post = @user.posts.create(
          title: "Rspecコントローラーテスト",
          body: "Rspecコントローラーテストの方法を解説",
          youtube_url: "youtube.com/watch?v=qpiKb0mdbr0&t=496s"
          )
      end

      context 'newアクションテスト' do
        # ログインユーザーでなければ、URL先のページ遷移が失敗するか？
        it "正常にレスポンスが返ってきていないか？" do
          # 成功した場合のsign_in @userを抜くことで、ログインしていない状況を作る
          get new_users_post_path
          expect(response).to_not be_successful
        end
        # 302（リクエストした先のページが一時的に移動されている）
        it "302レスポンスが返ってきているか？" do
          # 成功した場合のsign_in @userを抜くことで、ログインしていない状況を作る
          get new_users_post_path
          expect(response).to have_http_status "302"
        end
        # ログイン画面にリダイレクトされているか？
        it "ログイン画面にリダイレクトされているか？" do
          # 成功した場合のsign_in @userを抜くことで、ログインしていない状況を作る
          get new_users_post_path
          expect(response).to redirect_to "/users/sign_in"
        end
      end

      context 'showアクションテスト' do
        # ログインユーザーでなければ、URL先のページ遷移が失敗するか？
        it "正常にレスポンスが返ってきていないか？" do
          # 成功した場合のsign_in @userを抜くことで、ログインしていない状況を作る
          get users_post_path @post
          expect(response).to_not be_successful
        end
        # 302（リクエストした先のページが一時的に移動されている）
        it "302レスポンスが返ってきているか？" do
          # 成功した場合のsign_in @userを抜くことで、ログインしていない状況を作る
          get users_post_path @post
          expect(response).to have_http_status "302"
        end
        # ログイン画面にリダイレクトされているか？
        it "ログイン画面にリダイレクトされているか？" do
          # 成功した場合のsign_in @userを抜くことで、ログインしていない状況を作る
          get users_post_path @post
          expect(response).to redirect_to "/users/sign_in"
        end
      end

      context 'indexアクションテスト' do
        # ログインユーザーでなければ、URL先のページ遷移が失敗するか？
        it "正常にレスポンスが返ってきていないか？" do
          # 成功した場合のsign_in @userを抜くことで、ログインしていない状況を作る
          get users_posts_path
          expect(response).to_not be_successful
        end
        # 302（リクエストした先のページが一時的に移動されている）
        it "302レスポンスが返ってきているか？" do
          # 成功した場合のsign_in @userを抜くことで、ログインしていない状況を作る
          get users_posts_path
          expect(response).to have_http_status "302"
        end
        # ログイン画面にリダイレクトされているか？
        it "ログイン画面にリダイレクトされているか？" do
          # 成功した場合のsign_in @userを抜くことで、ログインしていない状況を作る
          get users_posts_path
          expect(response).to redirect_to "/users/sign_in"
        end
      end
    end
  end
  # describe "データの登録及び更新" do
  #   context "ログインを必要とするアクション" do
  #     let(:user) { FactoryBot.create(:user) }
  #     let(:login_user) { login(user) }
  #     let(:post_params) { { title: "Rspecコントローラーテスト", body: "Rspecコントローラーテストの方法を解説", youtube_url: "youtube.com/watch?v=qpiKb0mdbr0&t=496s" } }
  #     let(:new_post)  { create(:post, user: user) } #変数名変更

  #     describe "createアクション" do
  #       context "ログイン済みユーザーの場合" do
  #         it "投稿を作成する" do
  #           sign_in user
  #           expect {
  #             post users_posts_path(new_post), params: { post: post_params }
  #           }.to change(user.posts, :count).by(1)
  #         end
  #       end
  #     end
  #   end
  # end
end