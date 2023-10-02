require 'rails_helper'

RSpec.describe '/posts', type: :request do

  let(:user) { create(:user) }
  let(:admin) { create(:admin) }

  let(:valid_user_post) do
    FactoryBot.create(:post, :valid_post, user: user)
  end

  let(:valid_admin_post) do
    FactoryBot.create(:post, :valid_post, admin: admin)
  end

  let(:invalid_user_post) do
    FactoryBot.attributes_for(:post, user: user)
  end

  let(:invalid_admin_post) do
    FactoryBot.attributes_for(:post, admin: admin)
  end

  describe 'GET /index (ユーザー)' do
    before(:each) do
      valid_user_post
      user.confirm
      sign_in user
    end

    it '成功したレスポンスを返すこと' do
      get users_posts_path
      expect(response).to be_successful
    end
  end

  describe 'GET /index (管理者)' do
    before(:each) do
      valid_admin_post
      admin.confirm
      sign_in admin
    end

    it '成功したレスポンスを返すこと' do
      get admins_posts_path
      expect(response).to be_successful
    end
  end

  describe 'GET /show (ユーザー)' do
    before(:each) do
      valid_user_post
      user.confirm
      sign_in user
    end

    it '成功したレスポンスを返すこと' do
      get users_post_path(valid_user_post)
      expect(response).to be_successful
    end
  end

  describe 'GET /show (管理者)' do
    before(:each) do
      valid_admin_post
      admin.confirm
      sign_in admin
    end

    it '成功したレスポンスを返すこと' do
      get admins_post_path(valid_user_post)
      expect(response).to be_successful
    end
  end

  describe 'GET /new (ユーザー)' do
    before(:each) do
      valid_user_post
      user.confirm
      sign_in user
    end

    it '成功したレスポンスを返すこと' do
      get new_users_post_path
      expect(response).to be_successful
    end
  end

  describe 'GET /new (管理者)' do
    before(:each) do
      admin.confirm
      sign_in admin
    end

    it '成功したレスポンスを返すこと' do
      get new_admins_post_path
      expect(response).to be_successful
    end
  end

  describe 'GET /edit (ユーザー)' do
    before(:each) do
      valid_user_post
      user.confirm
      sign_in user
    end

    it '成功したレスポンスを返すこと' do
      get edit_users_post_path(valid_user_post)
      expect(response).to be_successful
    end
  end

  describe 'GET /edit (管理者)' do
    before(:each) do
      valid_admin_post
      admin.confirm
      sign_in admin
    end

    it '成功したレスポンスを返すこと' do
      get edit_admins_post_path(valid_admin_post)
      expect(response).to be_successful
    end
  end

  describe 'POST /create (ユーザー)' do
    context '有効なパラメータの場合(ユーザー)' do
      before(:each) do
        valid_user_post
        user.confirm
        sign_in user
      end

      it '新しいPostを作成すること' do
        post_attributes = FactoryBot.attributes_for(:post, :valid_post)
        expect {
          post users_posts_path, params: { post: post_attributes }
        }.to change(Post, :count).by(1)
      end

      it '作成したpostの詳細ページにリダイレクトすること' do
        post_attributes = FactoryBot.attributes_for(:post, :valid_post)
        post users_posts_path, params: { post: post_attributes }
        expect(response).to redirect_to(users_post_path(Post.last))
      end
    end

    context '無効なパラメータの場合(ユーザー)' do
      before(:each) do
        valid_user_post
        user.confirm
        sign_in user
      end

      it '新しいPostを作成しないこと' do
        invalid_attributes = FactoryBot.attributes_for(:post)
        expect {
          post users_posts_path, params: { post: invalid_attributes }
        }.not_to change(Post, :count)
      end

      it "成功したレスポンスを返すこと（つまり、'動画投稿'を表示すること）" do
        post users_posts_path, params: { post: invalid_user_post }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'POST /create (管理者)' do
    context '有効なパラメータの場合(管理者)' do
      before(:each) do
        admin.confirm
        sign_in admin
      end

      it '新しいPostを作成すること' do
        post_attributes = FactoryBot.attributes_for(:post, :valid_post)
        expect {
          post admins_posts_path, params: { post: post_attributes }
        }.to change(Post, :count).by(1)
      end

      it '作成したpostにリダイレクトすること' do
        post_attributes = FactoryBot.attributes_for(:post, :valid_post)
        post admins_posts_path, params: { post: post_attributes }
        expect(response).to redirect_to(admins_post_path(Post.last))
      end
    end

    context '無効なパラメータの場合(管理者)' do
      before(:each) do
        admin.confirm
        sign_in admin
      end

      it '新しいPostを作成しないこと' do
        expect {
          post admins_posts_path, params: { post: invalid_admin_post }
        }.not_to change(Post, :count)
      end

      it "成功したレスポンスを返すこと（つまり、'動画投稿画面'を表示すること）" do
        post admins_posts_path, params: { post: invalid_admin_post }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH /update (ユーザー)' do
    before(:each) do
      valid_user_post
      user.confirm
      sign_in user
    end

    context '有効なパラメータの場合' do
      let(:new_valid_post) do
        { title: 'Ruby on Rails解説動画', body: 'Rspecについて詳しく解説した動画です。', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo' }
      end

      it '要求されたpostを更新すること' do
        post = valid_user_post
        patch users_post_path(post), params: { post: new_valid_post }
        post.reload
        expect(post.title).to eq('Ruby on Rails解説動画')
        expect(post.body).to eq('Rspecについて詳しく解説した動画です。')
        expect(post.youtube_url).to eq('https://www.youtube.com/watch?v=AgeJhUvEezo')
      end

      it 'postにリダイレクトすること' do
        post = valid_user_post
        patch users_post_path(post), params: { post: new_valid_post }
        expect(response).to redirect_to(users_posts_path(post))
      end
    end

    context '無効なパラメータの場合' do
      it "成功したレスポンスを返すこと（つまり、'動画編集画面'を表示すること）" do
        post = valid_user_post
        patch users_post_path(post), params: { post: invalid_user_post }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'PATCH /update (管理者)' do
    before(:each) do
      valid_admin_post
      admin.confirm
      sign_in admin
    end

    context '有効なパラメータの場合' do
      let(:new_valid_post) do
        { title: 'Ruby on Rails解説動画', body: 'Rspecについて詳しく解説した動画です。', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo' }
      end

      it '要求されたpostを更新すること' do
        post = valid_admin_post
        patch admins_post_path(post), params: { post: new_valid_post }
        post.reload
        expect(post.title).to eq('Ruby on Rails解説動画')
        expect(post.body).to eq('Rspecについて詳しく解説した動画です。')
        expect(post.youtube_url).to eq('https://www.youtube.com/watch?v=AgeJhUvEezo')
      end

      it 'postにリダイレクトすること' do
        post = valid_admin_post
        patch admins_post_path(post), params: { post: new_valid_post }
        expect(response).to redirect_to(admins_posts_path(post))
      end
    end

    context '無効なパラメータの場合' do
      it "成功したレスポンスを返すこと（つまり、'動画編集画面'を表示すること）" do
        post = valid_admin_post
        patch admins_post_path(post), params: { post: invalid_admin_post }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe 'DELETE /destroy (ユーザー)' do
    before(:each) do
      valid_user_post
      user.confirm
      sign_in user
    end

    it '要求されたpostを削除すること' do
      post = valid_user_post
      expect {
        delete users_post_path(post)
      }.to change(Post, :count).by(-1)
    end

    it 'postの一覧にリダイレクトすること' do
      post = valid_user_post
      delete users_post_path(post)
      expect(response).to redirect_to(users_posts_path)
    end
  end

  describe 'DELETE /destroy (管理者)' do
    before(:each) do
      valid_admin_post
      admin.confirm
      sign_in admin
    end

    it '要求されたpostを削除すること' do
      post = valid_admin_post
      expect {
        delete admins_post_path(post)
      }.to change(Post, :count).by(-1)
    end

    it 'postの一覧にリダイレクトすること' do
      post = valid_admin_post
      delete admins_post_path(post)
      expect(response).to redirect_to(admins_posts_path)
    end
  end
end
