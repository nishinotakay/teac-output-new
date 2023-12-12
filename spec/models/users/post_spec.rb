require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }
  let(:post) { build(:post, user: user) }

  describe 'バリデーション' do
    context '全ての項目が正しく入力されている時' do
      it '有効である' do
        expect(post).to be_valid
      end
    end

    context 'タイトルの文字数が30文字の場合' do
      it '有効である' do
        post = build(:post, user: user)
        post.title = Faker::Lorem.characters(number: 30)
        expect(post).to be_valid
      end
    end

    context 'タイトルの文字数が31文字以上の場合' do
      it '無効である' do
        post = build(:post, user: user)
        post.title = Faker::Lorem.characters(number: 31)
        expect(post).to be_invalid
        expect(post.errors[:title]).to include('は30文字以内で入力してください')
      end
    end

    context 'タイトルが空白の時' do
      it '無効である' do
        post = build(:post, title: nil, user: user)
        expect(post).to be_invalid
        expect(post.errors[:title]).to include('を入力してください')
      end
    end

    context '内容の文字数が240文字の場合' do
      it '有効である' do
        post.body = Faker::Lorem.characters(number: 240)
        expect(post).to be_valid
      end
    end

    context '内容の文字数が241文字以上の場合' do
      it '無効である' do
        post.body = Faker::Lorem.characters(number: 241)
        expect(post).to be_invalid
        expect(post.errors[:body]).to include('は240文字以内で入力してください')
      end
    end

    context '内容が空白の時' do
      it '無効である' do
        post = build(:post, body: nil, user: user)
        expect(post).to be_invalid
        expect(post.errors[:body]).to include('を入力してください')
      end
    end

    context 'URLが空白の時' do
      it '無効である' do
        post = build(:post, youtube_url: nil, user: user)
        expect(post).to be_invalid
        expect(post.errors[:youtube_url]).to include('を入力してください')
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'ユーザーと関連付けられている場合' do
      it '多:1となっている' do
        expect(Post.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context '投稿者の登録が削除された場合' do
      it '動画投稿も削除されること' do
        create(:post, user: user)
        expect { user.destroy }.to change(described_class, :count).by(-1)
      end
    end
  end

  describe '一覧表示の操作' do
    describe '並べ替え機能' do
      let!(:post_1) { create(:post, created_at: '2022-08-09') }
      let!(:post_2) { create(:post, created_at: '2022-10-25') }
      let!(:post_3) { create(:post, created_at: '2023-01-01') }

      it '古い順に並べ替えることができる' do
        posts = described_class.filtered_and_ordered_posts({ order: 'ASC'}, 1, 30)
        expect(posts).to eq([post_1, post_2, post_3])
      end

      it '新しい順に並べ替えることができる' do
        posts = described_class.filtered_and_ordered_posts({ order: 'DESC' }, 1, 30)
        expect(posts).to eq([post_3, post_2, post_1])
      end
    end

    describe '絞り込み検索機能' do
      let!(:user_1) { create(:user, name: '山田太郎') }
      let!(:user_2) { create(:user, name: '伊東美咲') }
      let!(:user_3) { create(:user, name: '伊藤英明') }

      context '名前を指定する場合' do
        let!(:post_1) { create(:post, user: user_1) }
        let!(:post_2) { create(:post, user: user_2) }
        let!(:post_3) { create(:post, user: user_3) }

        context '名前の一部を入力した場合' do
          it '前方一致した動画投稿が返ること' do
            posts = described_class.filtered_and_ordered_posts({ author: '伊' }, 1, 30).pluck(:id)
            expect(posts).to contain_exactly(post_2.id, post_3.id)
          end

          it '中央一致した動画投稿が返ること' do
            posts = described_class.filtered_and_ordered_posts({ author: '田' }, 1, 30).pluck(:id)
            expect(posts).to eq([post_1.id])
          end

          it '後方一致した動画投稿が返ること' do
            posts = described_class.filtered_and_ordered_posts({ author: '咲' }, 1, 30).pluck(:id)
            expect(posts).to eq([post_2.id])
          end
        end

        context 'フルネームを入力した場合' do
          it '完全一致した動画投稿が返ること' do
            posts = described_class.filtered_and_ordered_posts({ author: '伊東美咲' }, 1, 30)
            expect(posts.size).to eq(1)
          end
        end

        context '一致しない名前を指定した場合' do
          it '何も返らないこと' do
            posts = described_class.filtered_and_ordered_posts({ author: '拓也' }, 1, 30)
            expect(posts).to be_empty
          end
        end

        context "想定外の値を指定した場合" do
          context 'SQLが指定された場合' do
            it 'クエリが実行されないこと' do
              filter = { name: "SELECT * FROM posts WHERE name = '山田太郎';" } 
              allow(Post).to receive(:where).and_return([]) # データベースクエリをモックするためにRSpecのallowメソッドを使用
              result = Post.filtered_and_ordered_posts(filter, 1, 30)      
              expect(Post).not_to have_received(:where) # データベースクエリが実行されなかったことを確認
            end
          end

          context '正規表現が指定された場合' do
            it '正規表現が実行されないこと' do
              filter = { name: /伊東/ } # nameに正規表現を指定  
              allow(Post).to receive(:where).and_return([])
              result = Post.filtered_and_ordered_posts(filter, 1, 30)      
              expect(Post).not_to have_received(:where)
            end
          end
        end
      end

      context '投稿日を指定する場合' do
        let!(:post_1) { create(:post, created_at: '2022-08-09', user: user_1) }
        let!(:post_2) { create(:post, created_at: '2022-10-25', user: user_2) }
        let!(:post_3) { create(:post, created_at: '2023-01-01', user: user_3) }

        context '開始日のみ指定した場合' do
          it '開始日から今日までの動画投稿が返ること' do
            filter = { start: '2023-01-01' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30).pluck(:id)
            expect(posts).to eq([post_3.id])
          end
        end

        context '終了日のみ指定した場合' do
          it '終了日以前の動画投稿が返ること' do
            filter = { finish: '2022-10-25' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30).pluck(:id)
            expect(posts).to eq([post_2.id, post_1.id])
          end
        end

        context '開始日、終了日共に指定した場合' do
          it '指定期間内の動画投稿が返ること' do
            filter = { 
              start: '2022-06-01',
              finish: '2022-09-30'
            }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30).pluck(:id)
            expect(posts).to eq([post_1.id])
          end
        end

        context '一致しない投稿日を指定した場合' do
          it '何も返らないこと' do
            filter = { 
              start: '2023-02-01',
              finish: '2023-09-30'
            }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30)
            expect(posts).to be_empty
          end
        end

        context "想定外の値を指定した場合" do
          context 'SQLが指定された場合' do
            it 'クエリが実行されないこと' do
              filter = { 
                start: "SELECT * FROM posts WHERE created_at = '2022-08-09';",
                finish: "SELECT * FROM posts WHERE created_at = '2023-01-01';"
              } 
              allow(Post).to receive(:where).and_return([])
              result = Post.filtered_and_ordered_posts(filter, 1, 30)      
              expect(Post).not_to have_received(:where)
            end
          end

          context '正規表現が指定された場合' do
            it '正規表現が実行されないこと' do
              filter = { 
                start: /2022-08-09/,
                finish: /2023-01-01/
              }             
              allow(Post).to receive(:where).and_return([])
              result = Post.filtered_and_ordered_posts(filter, 1, 30)      
              expect(Post).not_to have_received(:where)
            end
          end
        end
      end

      context 'タイトルを指定する場合' do
        let!(:post_1) { create(:post, title: 'Ruby', user: user_1) }
        let!(:post_2) { create(:post, title: 'Rails', user: user_2) }
        let!(:post_3) { create(:post, title: 'SQL', user: user_3) }

        context 'タイトルの一部を入力した場合' do
          it '前方一致した動画投稿が返ること' do
            filter = { title: 'R' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30).pluck(:id)
            expect(posts).to eq([post_2.id, post_1.id])
          end

          it '中央一致した動画投稿が返ること' do
            filter = { title: 'Q' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30).pluck(:id)
            expect(posts).to eq([post_3.id])
          end

          it '後方一致した動画投稿が返ること' do
            filter = { title: 'y' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30).pluck(:id)
            expect(posts).to eq([post_1.id])
          end
        end

        context '完全一致したタイトルを入力した場合' do
          it '正しい動画投稿が返ること' do
            filter = { title: 'Rails' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30).pluck(:id)
            expect(posts).to eq([post_2.id])
          end
        end

        context '一致しないタイトルを入力した場合' do
          it '何も返らないこと' do
            filter = { title: 'PHP' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30)
            expect(posts).to be_empty
          end
        end
      end

      context '内容を指定する場合' do
        let!(:post_1) { create(:post, body: 'Rubyに関する動画', user: user_1) }
        let!(:post_2) { create(:post, body: 'Rails修得のための基礎知識', user: user_2) }
        let!(:post_3) { create(:post, body: 'SQLに関する動画', user: user_3) }

        context '内容の一部を入力した場合' do
          it '前方一致した動画投稿が返ること' do
            filter = { body: 'Ruby' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30).pluck(:id)
            expect(posts).to eq([post_1.id])
          end

          it '中央一致した動画投稿が返ること' do
            filter = { body: '関する' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30).pluck(:id)
            expect(posts).to eq([post_3.id, post_1.id])
          end

          it '後方一致した動画投稿が返ること' do
            filter = { body: '知識' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30).pluck(:id)
            expect(posts).to eq([post_2.id])
          end
        end

        context '完全一致した内容を入力した場合' do
          it '正しい動画投稿が返ること' do
            filter = { body: 'SQLに関する動画' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30)
            expect(posts.size).to eq(1)
          end
        end

        context '一致しない内容を指定した場合' do
          it '何も返らないこと' do
            filter = { body: 'PHPに関する動画' }
            posts = described_class.filtered_and_ordered_posts(filter, 1, 30)
            expect(posts).to be_empty
          end
        end

        context "想定外の値を指定した場合" do
          context 'SQLが指定された場合' do
            it 'クエリが実行されないこと' do
              filter = { body: "SELECT * FROM posts WHERE body = 'Ruby';" } 
              allow(Post).to receive(:where).and_return([]) 
              result = Post.filtered_and_ordered_posts(filter, 1, 30)     
              expect(Post).not_to have_received(:where)
            end
          end
        end

        context '正規表現が指定された場合' do
          it '正規表現が実行されないこと' do
            filter = { body: /Ruby/ }              
            allow(Post).to receive(:where).and_return([])
            result = Post.filtered_and_ordered_posts(filter, 1, 30)  
            expect(Post).not_to have_received(:where)            
          end
        end
      end

      context 'すべてのフォームが未入力の場合' do
        it 'すべての動画投稿が抽出されること' do
          filter = { order: 'DESC' }
          posts = described_class.filtered_and_ordered_posts(filter, 1, 30)
          expect(posts).to match_array(described_class.all)
        end
      end
    end
  end
end
