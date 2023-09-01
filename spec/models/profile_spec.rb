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
      FactoryBot.create(:profile, user: user)

      expect { user.destroy }.to change(described_class, :count).by(-1)
    end
  end

  describe '一覧表示の操作' do
    let!(:user1) { create(:user, name: '山田太郎', email: Faker::Internet.email, password: 'password') }
    let!(:user2) { create(:user, name: '伊東美咲', email: Faker::Internet.email, password: 'password') }
    let!(:profile1) { create(:profile, registration_date: '2023-08-09', hobby: 'ゲーム', user: user1) }
    let!(:profile2) { create(:profile, registration_date: '1999-10-25', hobby: 'ヨガ', user: user2) }

    describe '並べ替え機能' do
      it '古い順に並べ替えることができる' do
        oldest_first = described_class.sort_filter({ registration_date: 'ASC' }, {}).pluck(:id)
        expect(oldest_first).to eq([profile2.id, profile1.id])
      end

      it '新しい順に並べ替えることができる' do
        newest_first = described_class.sort_filter({ registration_date: 'DESC' }, {}).pluck(:id)
        expect(newest_first).to eq([profile1.id, profile2.id])
      end
    end

    describe '絞り込み機能' do
      context '名前を指定する場合' do
        context '名前の一部を入力した場合' do
          it '一致したプロフィールが返ること' do
            matching_name = described_class.sort_filter({}, { name: '太郎' }).pluck(:id)
            expect(matching_name).to eq([profile1.id])
          end
        end
        context "一致しない名前を指定した場合" do
          it '何も返らないこと' do
            matching_name = described_class.sort_filter({}, { name: '拓也' }).pluck(:id)
            expect(matching_name).to be_empty
          end
        end
      end

      context '登録日を指定する場合' do
        context "存在する登録日を指定した場合" do
          it '一致したプロフィールが返ること' do
            matching_registration_date = described_class.sort_filter({}, { registration_date: '2023-08-09' }).pluck(:id)
            expect(matching_registration_date).to eq([profile1.id])
          end
        end
        context "一致しない登録日を指定した場合" do
          it '何も返らないこと' do
            matching_registration_date = described_class.sort_filter({}, { registration_date: '2022-12-31' }).pluck(:id)
            expect(matching_registration_date).to be_empty
          end
        end
        context "空の登録日を指定した場合" do
          it "sort_filterメソッドが呼び出されても何もせず終了すること" do
            # sort_filterメソッドが呼び出されることを期待します
            expect(described_class).to receive(:sort_filter).and_call_original
        
            # 空の登録日を指定してsort_filterメソッドを呼び出します
            matching_registration_date = described_class.sort_filter({}, { registration_date: '' }).pluck(:id)
        
            # sort_filterメソッドの戻り値が空であることを確認します
            expect(matching_registration_date).to eq([])

          end
        end
      end

      context '趣味を指定する場合' do
        context '趣味の一部を入力した場合' do
          it '一致したプロフィールが返ること' do
            matching_hobby = described_class.sort_filter({}, { hobby: 'ヨ' }).pluck(:id)
            expect(matching_hobby).to eq([profile2.id])
          end
        end
        context "一致しない名前を指定した場合" do
          it '何も返らないこと' do
            matching_hobby = described_class.sort_filter({}, { hobby: '読書' }).pluck(:id)
            expect(matching_hobby).to be_empty
          end
        end
      end     
    end
  end
end
