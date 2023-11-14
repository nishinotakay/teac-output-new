require 'rails_helper'

RSpec.describe '/posts', type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  describe 'GET /index' do
    before(:each) do
      @post1 = create(:post, created_at: DateTime.new(2023, 11, 10))
      @post2 = create(:post, created_at: DateTime.new(2023, 11, 11))
      @post3 = create(:post, created_at: DateTime.new(2023, 11, 9))
    end

    context 'ユーザーがログインしている場合' do
      before(:each) do
        user.confirm
        sign_in user
      end

      it 'リクエストが成功すること' do
        get users_posts_url
        expect(response).to have_http_status(:ok)
      end

      it 'すべての動画を取得できること' do
        get users_posts_url, as: :json
        json = JSON.parse(response.body)
        expect(json.length).to eq(3)
      end

      it '並び順が正しいこと' do
        get users_posts_url, as: :json
        json = JSON.parse(response.body)

        expect(json.first['created_at']).to be >= @post2.created_at
        expect(json.second['created_at']).to be >= @post3.created_at
      end
    end

    context '管理者がログインしている場合' do
      before(:each) do
        admin.confirm
        sign_in admin
      end

      it 'リクエストが成功すること' do
        get admins_posts_url
        expect(response).to have_http_status(:ok)
      end

      it 'すべての動画を取得できること' do
        get admins_posts_url, as: :json
        json = JSON.parse(response.body)
        expect(json.length).to eq 3
      end

      it '並び順が正しいこと' do
        get admins_posts_url, as: :json
        json = JSON.parse(response.body)

        expect(json.first['created_at']).to be >= @post2.created_at
        expect(json.second['created_at']).to be >= @post3.created_at
      end
    end
  end

  describe 'GET /show' do
    let!(:valid_user_post) { create(:post, title: 'Ruby', body: 'Ruby解説', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', user: user) }
    let!(:valid_admin_post) { create(:post, title: 'SQL', body: 'SQL解説', youtube_url: 'https://www.youtube.com/watch?v=v-Mb2voyTbc', admin: admin) }

    context 'ユーザーがログインしている場合' do
      before(:each) do
        user.confirm
        sign_in user
      end
      context '自分の投稿を閲覧する場合' do
        it 'リクエストが成功すること' do
          get users_post_url(valid_user_post)
          expect(response).to have_http_status(:ok)
        end
        it '正確なタイトル名が返ってきていること' do
          get users_post_url(valid_user_post), as: :json
          json = JSON.parse(response.body)
          expect(json['title']).to eq 'Ruby'
        end
        it '正確な内容が返ってきていること' do
          get users_post_url(valid_user_post), as: :json
          json = JSON.parse(response.body)
          expect(json['body']).to eq 'Ruby解説'
        end
        it '正確なURLが返ってきていること' do
          get users_post_url(valid_user_post), as: :json
          json = JSON.parse(response.body)
          expect(json['youtube_url']).to eq 'https://www.youtube.com/watch?v=AgeJhUvEezo'
        end
      end

      context '他人の投稿を閲覧する場合' do
        it 'リクエストが成功すること' do
          get users_post_url(valid_admin_post)
          expect(response).to have_http_status(:ok)
        end
        it '正確なタイトル名が返ってきていること' do
          get users_post_url(valid_admin_post), as: :json
          json = JSON.parse(response.body)
          expect(json['title']).to eq 'SQL'
        end
        it '正確な内容が返ってきていること' do
          get users_post_url(valid_admin_post), as: :json
          json = JSON.parse(response.body)
          expect(json['body']).to eq 'SQL解説'
        end
        it '正確なURLが返ってきていること' do 
          get users_post_url(valid_admin_post), as: :json
          json = JSON.parse(response.body)
          expect(json['youtube_url']).to eq 'https://www.youtube.com/watch?v=v-Mb2voyTbc'
        end
      end
    end

    context '管理者がログインしている場合' do
      before(:each) do
        admin.confirm
        sign_in admin
      end
      context '自分の投稿を閲覧する場合' do
        it 'リクエストが成功すること' do
          get admins_post_url(valid_admin_post)
          expect(response).to have_http_status(:ok)
        end
        it '正確なタイトル名が返ってきていること' do
          get admins_post_url(valid_admin_post), as: :json
          json = JSON.parse(response.body)
          expect(json['title']).to eq 'SQL'
        end
        it '正確な内容が返ってきていること' do
          get admins_post_url(valid_admin_post), as: :json
          json = JSON.parse(response.body)
          expect(json['body']).to eq 'SQL解説'
        end
        it '正確なURLが返ってきていること' do
          get admins_post_url(valid_admin_post), as: :json
          json = JSON.parse(response.body)
          expect(json['youtube_url']).to eq 'https://www.youtube.com/watch?v=v-Mb2voyTbc'
        end
      end

      context '他人の投稿を閲覧する場合' do
        it 'リクエストが成功すること' do
          get admins_post_url(valid_user_post)
          expect(response).to have_http_status(:ok)
        end
        it '正確なタイトル名が返ってきていること' do
          get admins_post_url(valid_user_post), as: :json
          json = JSON.parse(response.body)
          expect(json['title']).to eq 'Ruby'
        end
        it '正確な内容が返ってきていること' do
          get admins_post_url(valid_user_post), as: :json
          json = JSON.parse(response.body)
          expect(json['body']).to eq 'Ruby解説'
        end
        it '正確なURLが返ってきていること' do
          get admins_post_url(valid_user_post), as: :json
          json = JSON.parse(response.body)
          expect(json['youtube_url']).to eq 'https://www.youtube.com/watch?v=AgeJhUvEezo'
        end
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
        expect(response).to have_http_status(:ok)
      end
    end

    context '管理者がログインしている場合' do
      before(:each) do
        admin.confirm
        sign_in admin
      end

      it 'リクエストが成功すること' do
        get new_admins_post_url
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'GET /edit' do
    let(:valid_user_post) { create(:post, title: 'Ruby', body: 'Ruby解説', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', user: user) }
    let(:valid_admin_post) { create(:post, title: 'SQL', body: 'SQL解説', youtube_url: 'https://www.youtube.com/watch?v=v-Mb2voyTbc', admin: admin) }

    context 'ユーザーがログインしている場合' do
      before(:each) do
        valid_user_post
        user.confirm
        sign_in user      
      end

      it 'リクエストが成功すること' do
        get edit_users_post_url(valid_user_post)
        expect(response).to have_http_status(:ok)
      end

      it '1件の動画が正確に返ってきていること' do
        get edit_users_post_url(valid_user_post), as: :json
      
        json_response = JSON.parse(response.body)
      
        transformed_response = {
          title: json_response['title'],
          body: json_response['body'],
          youtube_url: json_response['youtube_url']
        }
      
        expected_data = {
          title: valid_user_post.title,
          body: valid_user_post.body,
          youtube_url: valid_user_post.youtube_url
        }
      
        expect(transformed_response).to eq(expected_data)
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
        expect(response).to have_http_status(:ok)
      end

      it '1件の動画が正確に返ってきていること' do
        get edit_admins_post_url(valid_admin_post), as: :json
      
        json_response = JSON.parse(response.body)
      
        transformed_response = {
          title: json_response['title'],
          body: json_response['body'],
          youtube_url: json_response['youtube_url']
        }
      
        expected_data = {
          title: valid_admin_post.title,
          body: valid_admin_post.body,
          youtube_url: valid_admin_post.youtube_url
        }
      
        expect(transformed_response).to eq(expected_data)
      end
    end
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
          expect(response).to have_http_status(:ok)
        end

        it 'エラーが表示されること' do
          post users_posts_url, params: { post: invalid_user_post }
          expect(response.body).to include 'を入力してください'
        end
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

        it '作成した動画の詳細ページにリダイレクトすること' do
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
          expect(response).to have_http_status(:ok)
        end

        it 'エラーが表示されること' do
          post admins_posts_url, params: { post: invalid_admin_post }
          expect(response.body).to include 'を入力してください'
        end
      end
    end
  end

  describe 'PATCH /update' do
    context 'ユーザーがログインしている場合' do
      let(:valid_user_post) { create(:post, title: 'Ruby', user: user) }
      before(:each) do
        user.confirm
        sign_in user
      end

      context '有効なパラメータの場合' do
        let(:new_valid_post) do
          { title: 'Ruby on Rails解説動画', body: 'Rspecについて詳しく解説した動画です。', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo' }
        end

        it 'リクエストが成功すること' do
          patch users_post_url(valid_user_post), params: { post: new_valid_post }
          expect(response.status).to eq 302
        end

        it 'タイトルを更新できること' do
          new_title = 'Ruby on Rails解説動画'
          params = { post: { title: new_title, body: valid_user_post.body, youtube_url: valid_user_post.youtube_url } }
        
          patch users_post_url(valid_user_post), params: params
          valid_user_post.reload
          expect(valid_user_post.title).to eq('Ruby on Rails解説動画')
        end
        it '内容を更新できること' do
          new_body = 'Rspecについて詳しく解説した動画です。'
          params = { post: { title: valid_user_post.title, body: new_body, youtube_url: valid_user_post.youtube_url } }
        
          patch users_post_url(valid_user_post), params: params
          valid_user_post.reload
          expect(valid_user_post.body).to eq('Rspecについて詳しく解説した動画です。')

        end
        it 'URLを更新できること' do
          new_youtube_url = 'https://www.youtube.com/watch?v=abcdefghijk'
          params = { post: { title: valid_user_post.title, body: valid_user_post.body, youtube_url: new_youtube_url } }
        
          patch users_post_url(valid_user_post), params: params
          valid_user_post.reload
          expect(valid_user_post.youtube_url).to eq(new_youtube_url)
        end

        it '動画にリダイレクトすること' do
          patch users_post_url(valid_user_post), params: { post: new_valid_post }
          expect(response).to redirect_to(users_posts_url(valid_user_post))
        end
      end

      context '無効なパラメータの場合' do
        it 'リクエストが成功すること' do
          invalid_params = attributes_for(:post, title: nil, user: user)
          patch users_post_url(valid_user_post), params: { post: invalid_params }
          get edit_users_post_url(valid_user_post)
          expect(response).to have_http_status(:ok)
        end

        it 'タイトル名が変更されないこと' do
          invalid_params = attributes_for(:post, title: nil, user: user)
          expect {
            patch users_post_url(valid_user_post), params: { post: invalid_params }
          }.not_to change(Post.find(valid_user_post.id), :title)
        end
      end
    end

    context '管理者がログインしている場合' do
      let(:valid_admin_post) { create(:post, title: 'SQL', admin: admin) }
      before(:each) do
        admin.confirm
        sign_in admin
      end

      context '有効なパラメータの場合' do
        let(:new_valid_post) do
          { title: 'Ruby on Rails解説動画', body: 'Rspecについて詳しく解説した動画です。', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo' }
        end

        it 'リクエストが成功すること' do
          patch admins_post_url(valid_admin_post), params: { post: new_valid_post }
          expect(response.status).to eq 302
        end

        it 'タイトルを更新できること' do
          new_title = 'Ruby on Rails解説動画'
          params = { post: { title: new_title, body: valid_admin_post.body, youtube_url: valid_admin_post.youtube_url } }
        
          patch admins_post_url(valid_admin_post), params: params
          valid_admin_post.reload
          expect(valid_admin_post.title).to eq('Ruby on Rails解説動画')
        end
        it '内容を更新できること' do
          new_body = 'Rspecについて詳しく解説した動画です。'
          params = { post: { title: valid_admin_post.title, body: new_body, youtube_url: valid_admin_post.youtube_url } }
        
          patch admins_post_url(valid_admin_post), params: params
          valid_admin_post.reload
          expect(valid_admin_post.body).to eq('Rspecについて詳しく解説した動画です。')
        end
        it 'URLを更新できること' do
          new_youtube_url = 'https://www.youtube.com/watch?v=abcdefghijk'
          params = { post: { title: valid_admin_post.title, body: valid_admin_post.body, youtube_url: new_youtube_url } }
        
          patch admins_post_url(valid_admin_post), params: params
          valid_admin_post.reload
          expect(valid_admin_post.youtube_url).to eq(new_youtube_url)
        end

        it '動画にリダイレクトすること' do
          patch admins_post_url(valid_admin_post), params: { post: new_valid_post }
          expect(response).to redirect_to(admins_posts_url(valid_admin_post))
        end
      end

      context '無効なパラメータの場合' do
        it 'リクエストが成功すること' do
          invalid_admin_post = attributes_for(:post, title: nil, admin: admin)
          patch admins_post_url(valid_admin_post), params: { post: invalid_admin_post }
          get edit_admins_post_url(valid_admin_post)
          expect(response).to have_http_status(:ok)
        end

        it 'タイトル名が変更されないこと' do
          invalid_params = attributes_for(:post, title: nil, admin: admin)
          expect {
            patch admins_post_url(valid_admin_post), params: { post: invalid_params }
          }.not_to change(Post.find(valid_admin_post.id), :title)
        end
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:valid_user_post) { create(:post, title: 'Ruby', user: user) }
    let(:valid_admin_post) { create(:post, title: 'SQL', admin: admin) }

    context 'ユーザーがログインしている場合' do
      before(:each) do
        user.confirm
        sign_in user
        valid_user_post
      end

      it 'リクエストが成功すること' do
        delete users_post_url(valid_user_post)
        expect(response.status).to eq 302
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

      it 'リクエストが成功すること' do
        delete admins_post_url(valid_admin_post)
        expect(response.status).to eq 302
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
