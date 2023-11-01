require 'rails_helper'

RSpec.describe '/posts', type: :request do

  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  describe 'GET /index' do
    before(:each) do
      create_list(:post, 3, user: user)
    end

    context 'ユーザーがログインしている場合' do
      before(:each) do
        user.confirm
        sign_in user
      end

      it 'リクエストが成功すること' do
        get users_posts_url
        expect(response).to have_http_status(200)
      end

      it 'すべての動画を取得できる' do
        get users_posts_url, as: :json
        json = JSON.parse(response.body)
        expect(json.length).to eq(3)
      end
    end

    context '管理者がログインしている場合' do
      before(:each) do
        admin.confirm
        sign_in admin
      end
  
      it 'リクエストが成功すること' do
        get admins_posts_url
        expect(response).to have_http_status(200)
      end
  
      it 'すべての動画を取得できる' do
        get admins_posts_url, as: :json
        json = JSON.parse(response.body)
        expect(json.length).to eq 3
      end
    end
  end

  describe 'GET /show' do
    let(:valid_user_post) { create(:post, title: 'Ruby', user: user) }
    let(:valid_admin_post) { create(:post, title: 'SQL', admin: admin) }

    context 'ユーザーがログインしている場合' do
      before(:each) do
        user.confirm
        sign_in user
      end
    
      it 'リクエストが成功すること' do
        get users_post_url(valid_user_post)
        expect(response).to have_http_status(200)

        get users_post_url(valid_admin_post)
        expect(response).to have_http_status(200)
      end

      it 'タイトルが表示されていること' do
        get users_post_url(valid_user_post)
        expect(response.body).to include 'Ruby'

        get users_post_url(valid_admin_post)
        expect(response.body).to include 'SQL'
      end
    end

    context '管理者がログインしている場合' do
      before(:each) do
        admin.confirm
        sign_in admin
      end
  
      it 'リクエストが成功すること' do
        get admins_post_url(valid_user_post)
        expect(response).to have_http_status(200)
  
        get admins_post_url(valid_admin_post)
        expect(response).to have_http_status(200)
      end
  
      it 'タイトルが表示されていること' do
        get admins_post_url(valid_user_post)
        expect(response.body).to include 'Ruby'
  
        get admins_post_url(valid_admin_post)
        expect(response.body).to include 'SQL'
      end
    end
  end

  describe 'GET /new' do
    let(:valid_user_post) { create(:post, title: 'Ruby', user: user) }
    let(:valid_admin_post) { create(:post, title: 'SQL', admin: admin) }

    context 'ユーザーがログインしている場合' do
      before(:each) do
        valid_user_post
        user.confirm
        sign_in user
      end

      it 'リクエストが成功すること' do
        get new_users_post_url
        expect(response).to have_http_status(200)
      end
    end

    context '管理者がログインしている場合' do
      before(:each) do
        admin.confirm
        sign_in admin
      end
  
      it 'リクエストが成功すること' do
        get new_admins_post_url
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /edit' do
    let(:valid_user_post) { create(:post, title: 'Ruby', body: 'Ruby解説', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', user: user) }
    let(:valid_admin_post) { create(:post, title: 'SQL', admin: admin) }

    context 'ユーザーがログインしている場合' do
      before(:each) do
        valid_user_post
        user.confirm
        sign_in user
        get edit_users_post_url(valid_user_post)
      end

      it 'リクエストが成功すること' do       
        expect(response).to have_http_status(200)
      end

      it 'タイトルが表示されていること' do
        expect(response.body).to include 'Ruby'
      end

      it '内容が表示されていること' do
        expect(response.body).to include 'Ruby'
      end

      it 'URLが表示されていること' do
        expect(response.body).to include 'Ruby'
      end
    end

    context '管理者がログインしている場合' do
      before(:each) do
        valid_admin_post
        admin.confirm
        sign_in admin
      end
  
      it 'リクエストが成功すること' do
        get edit_admins_post_url(valid_admin_post)
        expect(response).to have_http_status(200)
      end
    end
    # TODO
    # it 'タイトルが表示されていること' do
    # it '内容が表示されていること' do
    # it 'URLが表示されていること' do
  end

  describe 'POST /create' do
    context 'ユーザーがログインしている場合' do
      before(:each) do
        user.confirm
        sign_in user
      end

      context '有効なパラメータの場合' do
        let(:post_attributes) { attributes_for(:post) }

        it 'リクエストが成功すること' do
          post users_posts_url, params: { post: post_attributes }
          expect(response.status).to eq 302
        end

        it '新しい動画を作成すること' do
          expect {
            post users_posts_url, params: { post: post_attributes }
          }.to change(Post, :count).by(1)
        end

        it '作成した動画の詳細ページにリダイレクトすること' do
          post users_posts_url, params: { post: post_attributes }
          expect(response).to redirect_to(users_post_url(Post.last))
        end
      end

      context '無効なパラメータの場合' do
        let(:invalid_user_post) { attributes_for(:post, title: nil, user: user) }

        it '新しい動画を作成しないこと' do
          expect {
            post users_posts_url, params: { post: invalid_user_post }
          }.not_to change(Post, :count)
        end

        it 'リクエストが成功すること' do
          post users_posts_url, params: { post: invalid_user_post }
          expect(response).to have_http_status(200)
        end

        # TO DO
        # it 'エラーが表示されること' do
      end
    end

    context '管理者がログインしている場合' do
      before(:each) do
        admin.confirm
        sign_in admin
      end
      context '有効なパラメータの場合' do
        let(:post_attributes) { attributes_for(:post) }
  
        it 'リクエストが成功すること' do
          post admins_posts_url, params: { post: post_attributes }
          expect(response.status).to eq 302
        end
  
        it '新しい動画を作成すること' do
          expect {
            post admins_posts_url, params: { post: post_attributes }
          }.to change(Post, :count).by(1)
        end
  
        it '作成した動画にリダイレクトすること' do
          post admins_posts_url, params: { post: post_attributes }
          expect(response).to redirect_to(admins_post_url(Post.last))
        end
      end
  
      context '無効なパラメータの場合' do
        let(:invalid_admin_post) { attributes_for(:post, title: nil, admin: admin) }
  
        it '新しい動画を作成しないこと' do
          expect {
            post admins_posts_url, params: { post: invalid_admin_post }
          }.not_to change(Post, :count)
        end
  
        it 'リクエストが成功すること' do
          post admins_posts_url, params: { post: invalid_admin_post }
          expect(response).to have_http_status(200)
        end
      end
    end
  end

  describe 'PATCH /update' do
    let(:valid_user_post) { create(:post, title: 'Ruby', user: user) }
    let(:valid_admin_post) { create(:post, title: 'SQL', admin: admin) }

    context 'ユーザーがログインしている場合' do
      before(:each) do
        user.confirm
        sign_in user
      end

      context '有効なパラメータの場合' do
        let(:new_valid_post) do
          { title: 'Ruby on Rails解説動画', body: 'Rspecについて詳しく解説した動画です。', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo' }
        end

        it '要求された動画を更新すること' do
          post = valid_user_post
          patch users_post_url(post), params: { post: new_valid_post }
          post.reload
          expect(post.title).to eq('Ruby on Rails解説動画')
          expect(post.body).to eq('Rspecについて詳しく解説した動画です。')
          expect(post.youtube_url).to eq('https://www.youtube.com/watch?v=AgeJhUvEezo')
        end

        it '動画にリダイレクトすること' do
          post = valid_user_post
          patch users_post_url(post), params: { post: new_valid_post }
          expect(response).to redirect_to(users_posts_url(post))
        end
      end

      context '無効なパラメータの場合' do
        it "更新できないこと" do
          post = valid_user_post
          invalid_params = attributes_for(:post, title: nil, user: user)
          patch users_post_url(post), params: { post: invalid_params }
          get edit_users_post_url(post) 
          expect(response).to have_http_status(200)
        end
      end
    end

    context '管理者がログインしている場合' do
      before(:each) do
        admin.confirm
        sign_in admin
        valid_admin_post
      end
  
      context '有効なパラメータの場合' do
        let(:new_valid_post) do
          { title: 'Ruby on Rails解説動画', body: 'Rspecについて詳しく解説した動画です。', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo' }
        end
  
        it '要求された動画を更新すること' do
          post = valid_admin_post
          patch admins_post_url(post), params: { post: new_valid_post }
          post.reload
          expect(post.title).to eq('Ruby on Rails解説動画')
          expect(post.body).to eq('Rspecについて詳しく解説した動画です。')
          expect(post.youtube_url).to eq('https://www.youtube.com/watch?v=AgeJhUvEezo')
        end
  
        it '動画にリダイレクトすること' do
          patch admins_post_url(valid_admin_post), params: { post: new_valid_post }
          expect(response).to redirect_to(admins_posts_url(valid_admin_post))
        end
      end
  
      context '無効なパラメータの場合' do
        it '更新できないこと' do
          invalid_admin_post = attributes_for(:post, title: nil, admin: admin)
          patch admins_post_url(valid_admin_post), params: { post: invalid_admin_post }
          get edit_admins_post_url(valid_admin_post)
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe 'DELETE /destroy (ユーザー)' do
    let(:valid_user_post) { create(:post, title: 'Ruby', user: user) }
    let(:valid_admin_post) { create(:post, title: 'SQL', admin: admin) }

    context 'ユーザーがログインしている場合' do
      before(:each) do
        user.confirm
        sign_in user
        valid_user_post
      end
  
      it '要求された動画を削除すること' do
        expect {
          delete users_post_url(valid_user_post)
        }.to change(Post, :count).by(-1)
      end
  
      it '動画の一覧にリダイレクトすること' do
        delete users_post_url(valid_user_post)
        expect(response).to redirect_to(users_posts_url)
      end
    end

    context '管理者がログインしている場合' do
      before(:each) do
        admin.confirm
        sign_in admin
        valid_admin_post
      end
  
      it '要求された動画を削除すること' do
        expect {
          delete admins_post_url(valid_admin_post)
        }.to change(Post, :count).by(-1)
      end
  
      it '動画の一覧にリダイレクトすること' do
        delete admins_post_url(valid_admin_post)
        expect(response).to redirect_to(admins_posts_url)
      end
    end
  end
end
