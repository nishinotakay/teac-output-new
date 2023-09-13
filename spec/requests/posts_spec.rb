require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/posts', type: :request do
  # Post. As you add validations to Post, be sure to
  # adjust the attributes here as well.

  let(:user) { FactoryBot.create(:user) }
  let(:admin) { FactoryBot.create(:admin) }
  
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

  # ユーザーがサインインして、既存の投稿がある場合、投稿一覧を取得できるか？
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

  # 管理者がサインインして、既存の投稿がある場合、投稿一覧を取得できるか？
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
  
  # ユーザーがサインインして新たな投稿を作成した場合、その投稿の詳細を取得できるか？
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

  # 管理者がサインインして新たな投稿を作成した場合、その投稿の詳細を取得できるか？
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

  # ユーザがサインインして新規投稿ボタンを押した場合、新規投稿ページへ遷移できるか？
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

  # 管理者がサインインして新規投稿ボタンを押した場合、新規投稿ページへ遷移できるか？
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
  
  # ユーザーがサインインして編集ボタンを押した場合、動画編集ページへ遷移できるか？
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

  # 管理者がサインインして編集ボタンを押した場合、動画編集ページへ遷移できるか？
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

  # ユーザーがサインインして動画投稿をしてpostレコードが1増えたか？、その際投稿した動画詳細ページへ遷移したか？
  # 無効なデータを投稿した際postレコードは増えず、動画投稿ページへレンダリングしたか？
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
        }.to change(Post, :count).by(0)
      end

      it "成功したレスポンスを返すこと（つまり、'動画投稿'を表示すること）" do
        post users_posts_path, params: { post: invalid_user_post }
        expect(response).to have_http_status(:ok)
      end
    end
  end  
    
  # 管理者がサインインして動画投稿をしてpostレコードが1増えたか？、その際投稿した動画詳細ページへ遷移したか？
  # 無効なデータを投稿した際postレコードは増えず、動画投稿ページへレンダリングしたか？
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
        }.to change(Post, :count).by(0)
      end

      it "成功したレスポンスを返すこと（つまり、'動画投稿画面'を表示すること）" do
        post admins_posts_path, params: { post: invalid_admin_post }
        expect(response).to have_http_status(:ok)
      end
    end
  end

  # ユーザーがサインインして有効な値で動画投稿を更新できるか？その際投稿した動画詳細ページへ遷移したか？
  # 無効なデータを投稿した際postレコードは増えず、動画編集ページへレンダリングしたか？
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

  # 管理者がサインインして有効な値で動画投稿を更新できるか？その際投稿した動画詳細ページへ遷移したか？
  # 無効なデータを投稿した際postレコードは増えず、動画編集ページへレンダリングしたか？
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
  
  # ユーザーがサインインして要求されたpostを削除できるか？その後、動画一覧ページへ遷移したか？
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

  # 管理者がサインインして要求されたpostを削除できるか？その後、動画一覧ページへ遷移したか？
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
