require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'バリデーション' do
    subject { FactoryBot.build(:profile, registration_date: registration_date, hobby: hobby) }

    context '全ての項目が入力されている場合' do
      let(:registration_date) { "2023-08-09" }
      let(:hobby) { "プログラミング" }
      it { is_expected.to be_valid }
    end

    context '登録日が入力されていない場合' do
      let(:registration_date) { "" }
      let(:hobby) { "プログラミング" }

      it do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq(['登録日を入力してください'])
      end
    end

    context '趣味が入力されていない場合' do
      let(:registration_date) { "2023-08-09" }
      let(:hobby) { "" }

      it do
        expect(subject).not_to be_valid
        expect(subject.errors.full_messages).to eq(['趣味を入力してください'])
      end
    end
  end
end
