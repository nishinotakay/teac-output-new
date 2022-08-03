require 'rails_helper'
RSpec.describe 'Profileモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    # factoriesで作成したダミーデータを使用します。
    let(:user) { FactoryBot.create(:user) }
    let!(:profile) { build(:profile, user_id: user.id) }

    # test_postを作成し、空欄での登録ができるか確認します。
    subject { test_profile.valid? }
    let(:test_profile) { profile }

    it "is valid with a name and a purpose" do
      @profile = Profile.new(
        name: "田中浩",
        purpose: "月収50万円",
      )
      expect(user).to be_valid
    end
    it "is invalid without a name" do
      @profile = Profile.new(
        name: nil,
        purpose: "月収50万円",
      )
      @profile.valid?
      expect(@profile.errors[:name]).to include("を入力してください")
    end
    context 'nameカラム' do
      it '空欄でないこと' do
        profile.name = ''
        is_expected.to eq false;
      end
      it '20文字以下であること' do
        profile.name = '月収50万円稼ぐrailsエンジニアの田中浩！'
        expect(profile.valid?).to eq false;
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
