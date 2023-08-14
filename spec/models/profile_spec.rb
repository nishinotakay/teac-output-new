require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'バリデーション' do
    subject { FactoryBot.build(:profile, registration_date: registration_date, hobby: hobby) }

    context '全ての項目が入力されている場合' do
      let(:registration_date) { '2023-08-09' }
      let(:hobby) { 'プログラミング' }

      it { expect(subject).to be_valid }
    end

    context '登録日が入力されていない場合' do
      let(:registration_date) { '' }
      let(:hobby) { 'プログラミング' }

      it do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq(['登録日を入力してください'])
      end
    end

    context '趣味が入力されていない場合' do
      let(:registration_date) { '2023-08-09' }
      let(:hobby) { '' }

      it do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq(['趣味を入力してください'])
      end
    end
  end

  describe 'アソシエーション' do
    it 'Userモデルとの関係が1:1となっていること' do
      association = described_class.reflect_on_association(:user)
      expect(association.macro).to eq :belongs_to
    end
  end

  describe 'dependentの確認' do
    it 'Userが削除されると関連するProfileも削除されること' do
      user = FactoryBot.create(:user)
      profile = FactoryBot.create(:profile, user: user)

      expect { user.destroy }.to change(Profile, :count).by(-1)
    end
  end
end
