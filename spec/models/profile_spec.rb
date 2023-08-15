require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'バリデーション' do
    context '登録日と趣味が入力されている場合' do
      profile = FactoryBot.build(:profile)
      profile.registration_date = '2023-08-09' 
      profile.hobby = 'プログラミング' 

      it '有効である' do 
        expect(profile).to be_valid
      end
    end

    context '登録日が入力されていない場合' do
      profile = FactoryBot.build(:profile)
      profile.registration_date = ''

      it '無効である' do
        expect(profile).to be_invalid
        expect(profile.errors.full_messages).to eq(['登録日を入力してください'])
      end
    end

    context '趣味が入力されていない場合' do
      profile = FactoryBot.build(:profile) 
      profile.hobby = '' 

      it '無効である' do
        expect(profile).to be_invalid
        expect(profile.errors.full_messages).to eq(['趣味を入力してください'])
      end
    end
  end

  describe 'アソシエーション' do
    it 'Userモデルとの関係が1:1となっていること' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end

    it 'Userが削除されると関連するProfileも削除されること' do
      user = FactoryBot.create(:user)
      profile = FactoryBot.create(:profile, user: user)

      expect { user.destroy }.to change(Profile, :count).by(-1)
    end
  end
end
