require 'rails_helper'
RSpec.describe 'Profileモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    # factoriesで作成したダミーデータを使用します。
    # test_postを作成し、空欄での登録ができるか確認します。
    subject { test_profile.valid? }

    let(:user) { FactoryBot.create(:user, :a) }
    let(:test_profile) { profile }
    let!(:profile) { build(:profile, user_id: user.id) }

    it 'is valid with a purpose' do
      profile = Profile.new(purpose: '月収50万円')
      expect(profile.purpose).to eq '月収50万円'
    end

    it 'is invalid without a purpose' do
      profile = Profile.new(
        purpose: nil
      )
      profile.valid?
      expect(profile.errors[:purpose]).to include('を入力してください')
    end

    context 'purposeカラム' do
      it '空欄でないこと' do
        profile.purpose = ''
        expect(subject).to eq false
      end
    end

    describe 'アソシエーションのテスト' do
      context 'custmerモデルとの関係' do
        it 'N:1となっている' do
          expect(Profile.reflect_on_association(:user).macro).to eq :belongs_to
        end
      end
    end
  end
end
