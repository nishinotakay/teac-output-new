require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  describe "[Action test]" do
    before do
      @user = FactoryBot.create(:user, :a)
    end

    context "new" do
      it "access by user" do
        sign_in @user
        get '/profiles/new'
        expect(response).to be_truthy
      end

      it "access by guest" do
        get '/profiles/new'
        expect(response).to have_http_status(302)
      end

      it "show" do
        profile = Profile.create(
          name: "test",
          purpose: "test",
          user_id: "1",
        )
        get users_profiles_path(profile)
        expect(response).to be_truthy
      end
    end
  end
end
