require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe 'バリデーション' do
    context '登録日と趣味が入力されている場合' do
      let(:profile) { FactoryBot.build(:profile, registration_date: '2023-08-09', hobby: 'プログラミング') }

      it '有効である' do
        expect(profile).to be_valid
      end
    end

    context '登録日が入力されていない場合' do
      let(:profile) { FactoryBot.build(:profile, registration_date: '', hobby: 'プログラミング') }

      it '無効である' do
        expect(profile).to be_invalid
        expect(profile.errors.full_messages).to eq(['登録日を入力してください'])
      end
    end

    context '趣味が入力されていない場合' do
      let(:profile) { FactoryBot.build(:profile, registration_date: '2023-08-09', hobby: '') }

      it '無効である' do
        expect(profile).to be_invalid
        expect(profile.errors.full_messages).to eq(['趣味を入力してください'])
      end
    end
  end

  describe 'アソシエーション' do
    context 'ユーザーと関連付けられている場合' do
      it '1:1になっていること' do
        association = described_class.reflect_on_association(:user)
        expect(association.macro).to eq :belongs_to
      end
    end

    context 'ユーザーが削除された場合' do
      it 'プロフィールも削除されること' do
        user = FactoryBot.create(:user)
        FactoryBot.create(:profile, user: user)

        expect { user.destroy }.to change(described_class, :count).by(-1)
      end
    end
  end

  describe '一覧表示の操作' do
    let!(:user1) { create(:user, name: '山田太郎', email: Faker::Internet.email, password: 'password') }
    let!(:user2) { create(:user, name: '伊東美咲', email: Faker::Internet.email, password: 'password') }
    let!(:profile1) { create(:profile, registration_date: '2023-08-09', hobby: 'ゲーム', user: user1) }
    let!(:profile2) { create(:profile, registration_date: '1999-10-25', hobby: 'ランニング', user: user2) }

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
          it '前方一致したプロフィールが返ること' do
            matching_name = described_class.sort_filter({}, { name: '山' }).pluck(:id)
            expect(matching_name).to eq([profile1.id])
          end

          it '中央一致したプロフィールが返ること' do
            matching_name = described_class.sort_filter({}, { name: '田' }).pluck(:id)
            expect(matching_name).to eq([profile1.id])
          end

          it '後方一致したプロフィールが返ること' do
            matching_name = described_class.sort_filter({}, { name: '咲' }).pluck(:id)
            expect(matching_name).to eq([profile2.id])
          end
        end

        context '一致しない名前を指定した場合' do
          it '何も返らないこと' do
            matching_name = described_class.sort_filter({}, { name: '拓也' }).pluck(:id)
            expect(matching_name).to be_empty
          end
        end

        context "想定外の値を指定した場合" do
          context 'SQLが指定された場合' do
            it 'クエリが実行されないこと' do
              filter = { name: 'SELECT * FROM profiles WHERE some_condition' } 
              allow(Profile).to receive(:where).and_return([]) # データベースクエリをモックするためにRSpecのallowメソッドを使用
              result = Profile.sort_filter({}, filter)      
              expect(Profile).not_to have_received(:where) # データベースクエリが実行されなかったことを確認
            end
          end

          context '正規表現が指定された場合' do
            it '正規表現が実行されないこと' do
              filter = { name: /伊東/ } # nameに正規表現を指定  
              allow(Profile).to receive(:where).and_return([])
              result = Profile.sort_filter({}, filter)      
              expect(Profile).not_to have_received(:where)
            end
          end
        end
      end

      context '登録日を指定する場合' do
        context '存在する登録日を指定した場合' do
          it '一致したプロフィールが返ること' do
            matching_registration_date = described_class.sort_filter({}, { registration_date: '2023-08-09' }).pluck(:id)
            expect(matching_registration_date).to eq([profile1.id])
          end
        end

        context '一致しない登録日を指定した場合' do
          it '何も返らないこと' do
            matching_registration_date = described_class.sort_filter({}, { registration_date: '2022-12-31' }).pluck(:id)
            expect(matching_registration_date).to be_empty
          end
        end

        context "想定外の値を指定した場合" do
          context 'SQLが指定された場合' do
            it 'クエリが実行されないこと' do
              filter = { registration_date: 'SELECT * FROM profiles WHERE some_condition' } 
              allow(Profile).to receive(:where).and_return([])
              result = Profile.sort_filter({}, filter)      
              expect(Profile).not_to have_received(:where)
            end
          end

          context '正規表現が指定された場合' do
            it '正規表現が実行されないこと' do
              filter = { registration_date: /2023-08-09/ }             
              allow(Profile).to receive(:where).and_return([])
              result = Profile.sort_filter({}, filter)      
              expect(Profile).not_to have_received(:where)
            end
          end
        end
      end

      context '趣味を指定する場合' do
        context '趣味の一部を入力した場合' do
          it '前方一致したプロフィールが返ること' do
            matching_hobby = described_class.sort_filter({}, { hobby: 'ラ' }).pluck(:id)
            expect(matching_hobby).to eq([profile2.id])
          end

          it '中央一致したプロフィールが返ること' do
            matching_hobby = described_class.sort_filter({}, { hobby: 'ニン' }).pluck(:id)
            expect(matching_hobby).to eq([profile2.id])
          end

          it '後方一致したプロフィールが返ること' do
            matching_hobby = described_class.sort_filter({}, { hobby: 'ム' }).pluck(:id)
            expect(matching_hobby).to eq([profile1.id])
          end
        end

        context '一致しない趣味を指定した場合' do
          it '何も返らないこと' do
            matching_hobby = described_class.sort_filter({}, { hobby: '読書' }).pluck(:id)
            expect(matching_hobby).to be_empty
          end
        end

        context "想定外の値を指定した場合" do
          context 'SQLが指定された場合' do
            it 'クエリが実行されないこと' do
              filter = { hobby: 'SELECT * FROM profiles WHERE some_condition' } 
              allow(Profile).to receive(:where).and_return([]) 
              result = Profile.sort_filter({}, filter)      
              expect(Profile).not_to have_received(:where)
            end
          end

          context '正規表現が指定された場合' do
            it '正規表現が実行されないこと' do
              filter = { hobby: /ゲーム/ }              
              allow(Profile).to receive(:where).and_return([])
              result = Profile.sort_filter({}, filter)   
              expect(Profile).not_to have_received(:where)            
            end
          end
        end
      end

      context 'すべてのフォームが未入力の場合' do
        it 'すべてのプロフィールが抽出されること' do
          filter = { name: '', registration_date: '', hobby: '' }
          profiles = described_class.sort_filter({}, filter)
          expect(profiles).to match_array(described_class.all)
        end
      end
    end
  end
end
