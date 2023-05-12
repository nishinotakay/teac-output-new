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

      it 'show' do
        sign_in user
        profile = Profile.create(
          learning_start: '2020/01/01',
          purpose:        'test',
          user_id:        1
        )
        get users_profiles_path(profile)
        expect(response).to be_truthy
      end
    end
  end
end
