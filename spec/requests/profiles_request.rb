require 'rails_helper'

RSpec.describe 'Profiles', type: :request do
  describe '[Action test]' do
    let(:user) { FactoryBot.create(:user, :a) }

    context 'new' do
      it 'access by user' do
        sign_in user
        get '/profiles/new'
        expect(response).to be_truthy
      end

      # it "access by guest" do
      #   get '/profiles/new'
      #   expect(response).to have_http_status(:found)
      #   # HTTPリクエスト302リクエストされたURIが一時的に変更されたことを意味する ログインしていないユーザーがNewアクションをリクエストすると、ログイン画面に移るので、このように記述している
      # end

      it 'show' do
        sign_in user
        profile = Profile.create(
          name:    'test',
          purpose: 'test',
          user_id: 1
        )
        get users_profiles_path(profile)
        expect(response).to be_truthy
      end
      # context "create" do
      #   it "access by user" do
      #     sign_in @user
      #     profile "/profiles", :params => { :profile => { :name => "test", :purpose => "test", :user_id => 1}}
      #     expect(response).to have_http_status(:ok)
      #   end
      #   it 'indexアクションにリクエストするとレスポンスに投稿済みのツイートのテキストが存在する' do
      #     get users_profiles_path(@profile)
      #     expect(response.body).to include(@profile.text)
      #   end
      #   it "access by guest" do
      #     profile "/profiles"
      #     expect(response).to have_http_status(:unauthorized)
      #     # HTTPリクエスト401未認証
      #   end
      # end
    end
  end
end
