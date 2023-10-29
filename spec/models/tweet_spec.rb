require 'rails_helper'

RSpec.describe Tweet, type: :model do
  describe '#valid?' do
    let(:user) { create(:user, name: '山田太郎', email: Faker::Internet.email, password: 'password', created_at: '2021-12-31') }
    let!(:tweet) { create(:tweet, post: "it's a sunny day!", created_at: '2022-01-01 00:00:00', user: user) }

    context '投稿フォームに1文字入力されている場合' do
      before(:each) do
        tweet.post = 'c' * 1
      end

      it 'バリデーションをパスする' do
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context '投稿が入力されていない場合' do
      before(:each) do
        tweet.post = ''
      end

      it 'バリデーションをパスしない' do
        expect(tweet.valid?).to eq(false)
        expect(tweet.errors.full_messages).to eq(['投稿内容を入力してください'])
      end
    end

    context '投稿フォームに255文字以内で入力されている場合' do
      before(:each) do
        tweet.post = 'c' * 255
      end

      it 'バリデーションをパスする' do
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context '投稿フォームに255文字より多く入力されている場合' do
      before(:each) do
        tweet.post = 'c' * 256
      end

      it 'バリデーションをパスしない' do
        expect(tweet.valid?).to eq(false)
        expect(tweet.errors.full_messages).to eq(['投稿内容は255文字以内で入力してください'])
      end
    end

    context '4つ以内の画像データをアップロードする場合' do
      before(:each) do
        4.times do |i|
          tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', "test#{i + 1}.png"),
            filename: "test#{i + 1}.png", content_type: 'image/png'))
        end
      end

      it 'バリデーションをパスする。' do
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context '4つよりも多いの画像データをアップロードする場合' do
      before(:each) do
        5.times do |i|
          tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', "test#{i + 1}.png"),
            filename: "test#{i + 1}.png", content_type: 'image/png'))
        end
      end

      it 'バリデーションをパスしない' do
        expect(tweet.valid?).to eq(false)
        expect(tweet.errors.full_messages).to eq(['Imagesは4つまでしかアップロードできません。'])
      end
    end

    context '5MB以下の画像データをアップロードする場合' do
      before(:each) do
        tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_5mb.jpg'),
          filename: 'test5mb.jpg', content_type: 'image/jpeg'))
      end

      it 'バリデーションをパスする' do
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context '5MBよりも大きな画像データをアップロードする場合' do
      before(:each) do
        tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_6mb.jpg'),
          filename: 'test6mb.jpg', content_type: 'image/jpeg'))
      end

      it 'バリデーションをパスしない' do
        expect(tweet.valid?).to eq(false)
        expect(tweet.errors.full_messages).to eq(['Imagesは1つのファイル5MB以内にして下さい。'])
      end
    end

    context 'jpeg形式、png形式以外のファイルをアップロードする場合' do
      before(:each) do
        tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_csv.csv'), filename: 'test_csv.csv', content_type: 'text/csv'))
      end

      it 'バリデーションをパスしない' do
        expect(tweet.valid?).to eq(false)
        expect(tweet.errors.full_messages).to eq(['Imagesはpng形式またはjpeg形式でアップロードして下さい。'])
      end
    end

    shared_examples 'jpeg、jpg、pngのファイルをアップロードする場合' do |filename, content_type|
      before(:each) do
        tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', filename), filename: filename, content_type: content_type))
      end

      it "#{content_type}はバリデーションをパスする" do
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context 'jpegファイルをアップロードする場合' do
      it_behaves_like 'jpeg、jpg、pngのファイルをアップロードする場合', 'test_jpeg.jpeg', 'image/jpeg'
    end

    context 'jpgファイルをアップロードする場合' do
      it_behaves_like 'jpeg、jpg、pngのファイルをアップロードする場合', 'test_jpg.jpg', 'image/jpeg'
    end

    context 'pngファイルをアップロードする場合' do
      it_behaves_like 'jpeg、jpg、pngのファイルをアップロードする場合', 'test_png.png', 'image/png'
    end
  end

  describe 'association' do
    let(:user) { create(:user, name: '山田太郎', email: Faker::Internet.email, password: 'password', created_at: '2021-12-31') }
    let!(:tweet) { create(:tweet, post: "it's a sunny day!", created_at: '2022-01-01 00:00:00', user: user) }

    context 'つぶやきが存在する場合' do
      it 'ユーザーと関連付けられる' do
        expect(tweet.user_id).to eq(user.id)
      end
    end
  end

  describe '#destroy' do
    let(:user) { create(:user, name: '山田太郎', email: Faker::Internet.email, password: 'password', created_at: '2021-12-31') }
    let!(:tweet) { create(:tweet, post: "it's a sunny day!", created_at: '2022-01-01 00:00:00', user: user) }
    let!(:tweet_comment) { FactoryBot.create_list(:tweet_comment, 3, content: 'tweet_comment_test', user: user, tweet: tweet, recipient_id: tweet.user_id) }

    context 'つぶやきを削除する場合' do
      it '3つの関連付けられたtweet_commentsが削除される' do
        expect { tweet.destroy }.to change { TweetComment.count }.by(-3)
      end
    end
  end

  describe '#apply_and_sort_query' do
    let(:user) { create(:user, name: '山田太郎', email: Faker::Internet.email, password: 'password', created_at: '2021-12-31') }
    let!(:tweet) { create(:tweet, post: "it's a sunny day!", created_at: '2022-01-01 00:00:00', user: user) }
    let(:user_1) { create(:user, name: '山下達郎', email: Faker::Internet.email, password: 'password') }
    let!(:tweet_1) { create(:tweet, post: 'ミュージックday!', created_at: '2023-04-01', user: user_1) }
    let!(:tweet_2) { create(:tweet, post: '2021年のポスト', created_at: '2021-12-31 23:59:59', user: user_1) }

    context '絞り込み検索' do
      context '投稿者の名前を完全一致で検索する場合' do
        let(:filter) { { author: '山田太郎', order: 'DESC' } }

        it '一致した件数を返すこと' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.count).to eq(1)
        end
      end

      context '投稿者の名前を前方一致で検索する場合' do
        let(:filter) { { author: '山', order: 'DESC' } }

        it '一致した件数を返すこと' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.count).to eq(2)
        end
      end

      context '投稿者の名前を中央一致で検索する場合' do
        let(:filter) { { author: '田', order: 'DESC' } }

        it '一致した件数を返すこと' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.count).to eq(1)
        end
      end

      context '投稿者の名前を後方一致で検索する場合' do
        let(:filter) { { author: '郎', order: 'DESC' } }

        it '一致した件数を返すこと' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.count).to eq(2)
        end
      end

      context '存在しない投稿者の名前を検索する場合' do
        let(:filter) { { author: '存在しない', order: 'DESC' } }

        it 'つぶやき一覧の件数が0になること' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.count).to eq(0)
        end
      end

      context '投稿内容を完全一致で検索する場合' do
        let(:filter) { { post: "it's a sunny day!", order: 'DESC' } }

        it '一致した件数を返すこと' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.count).to eq(1)
        end
      end

      context '投稿内容を前方一致で検索する場合' do
        let(:filter) { { post: "it's", order: 'DESC' } }

        it '一致した件数を返すこと' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.count).to eq(1)
        end
      end

      context '投稿内容を中央一致で検索する場合' do
        let(:filter) { { post: 'sunny', order: 'DESC' } }

        it '一致した件数を返すこと' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.count).to eq(1)
        end
      end

      context '投稿内容を後方一致で検索する場合' do
        let(:filter) { { post: 'day!', order: 'DESC' } }

        it '一致した件数を返すこと' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.count).to eq(2)
        end
      end

      context '存在しない投稿内容を検索する場合' do
        let(:filter) { { post: '存在しない', order: 'DESC' } }

        it 'つぶやき投稿一覧の件数が0になる' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.count).to eq(0)
        end
      end

      context '開始日,終了日ともに日付範囲を指定しない場合' do
        let(:filter) { { order: 'DESC' } }

        it '2022年1月1日から本日までをフィルタリングすること' do
          search_tweets = described_class.apply_and_sort_query(filter)
          search_tweets.each do |tweet|
            expect(tweet.created_at).to be >= Time.zone.parse('2022-01-01 00:00:00')
            expect(tweet.created_at).to be <= Time.zone.parse(Date.current.to_s).end_of_day
          end
          expect(search_tweets.count).to eq(2)
          expect(search_tweets).not_to include(tweet_2)
        end
      end

      context '開始日,終了日ともに日付範囲を指定する場合' do
        let(:filter) { { start: '2021-12-31', finish: '2023-10-01', order: 'DESC' } }

        it '指定した日付範囲がフィルタリングされること' do
          search_tweets = described_class.apply_and_sort_query(filter)
          search_tweets.each do |tweet|
            expect(tweet.created_at).to be >= Time.zone.parse(filter[:start])
            expect(tweet.created_at).to be <= Time.zone.parse(filter[:finish])
          end
          expect(search_tweets.count).to eq(3)
        end
      end

      context '開始日のみ日付範囲を指定する場合' do
        let(:filter) { { start: '2022-04-01', order: 'DESC' } }

        it '指定した日付から本日までの日付範囲がフィルタリングされること' do
          search_tweets = described_class.apply_and_sort_query(filter)
          search_tweets.each do |tweet|
            expect(tweet.created_at).to be >= Time.zone.parse('2022-04-01')
            expect(tweet.created_at).to be <= Time.zone.parse(Date.current.to_s).end_of_day
          end
        end
      end

      context '終了日のみ日付範囲を指定する場合' do
        let(:filter) { { finish: '2022-04-01', order: 'DESC' } }

        it '2022/1/1から指定された日までの日付範囲がフィルタリングされること' do
          search_tweets = described_class.apply_and_sort_query(filter)
          search_tweets.each do |tweet|
            expect(tweet.created_at).to be >= Time.zone.parse('2022-01-01')
            expect(tweet.created_at).to be <= Time.zone.parse('2022-04-01')
          end
          expect(search_tweets).not_to include(tweet_2)
        end
      end
    end

    context '並び替え' do
      context '新しい順を押下する場合' do
        let(:filter) { { order: 'DESC' } }

        it '降順の投稿日時の配列を返すこと' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.map { |tweet| tweet.created_at }).to eq [Time.zone.parse('2023-04-01'), Time.zone.parse('2022-01-01')]
        end
      end

      context '古い順を押下する場合' do
        let(:filter) { { order: 'ASC' } }

        it '昇順の投稿日時の配列を返すこと' do
          search_tweets = described_class.apply_and_sort_query(filter)
          expect(search_tweets.map { |tweet| tweet.created_at }).to eq [Time.zone.parse('2022-01-01'), Time.zone.parse('2023-04-01')]
        end
      end
    end
  end

  describe '#build_filter' do
    context '投稿日時の並び順を指定しない場合' do
      let(:params) do
        {
          author: '山',
          post:   'day',
          start:  '2021-12-31',
          finish: '2023-04-01',
          order:  nil
        }
      end

      it 'params[:order]に"DESC"を返すこと' do
        filter = described_class.build_filter(params)
        expect(filter[:order]).to eq('DESC')
      end
    end

    context '投稿日時の並び順を指定する場合' do
      context '新しい順に指定する場合' do
        let(:params) do
          {
            author: '山',
            post:   'day',
            start:  '2021-12-31',
            finish: '2023-04-01',
            order:  'DESC'
          }
        end

        it 'params[:order]に"DESC"を返すこと' do
          filter = described_class.build_filter(params)
          expect(filter[:order]).to eq('DESC')
        end
      end

      context '古い順に指定する場合' do
        let(:params) do
          {
            author: '山',
            post:   'day',
            start:  '2021-12-31',
            finish: '2023-04-01',
            order:  'ASC'
          }
        end

        it 'params[:order]に"ASC"を返すこと' do
          filter = described_class.build_filter(params)
          expect(filter[:order]).to eq('ASC')
        end
      end
    end
  end

  describe '#self.tweet_and_image' do
    let(:user_with_image) { create(:user) }
    let(:user_without_image) { create(:user) }
    let(:profile_with_image) { create(:profile, user: user_with_image) }
    let(:profile_without_image) { create(:profile, user: user_without_image) }

    before(:each) do
      profile_with_image.image.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test1.png'),
        filename: 'test1.png', content_type: 'image/png'))
      create_list(:tweet, 2, user: user_with_image)

      profile_without_image
      create_list(:tweet, 2, user: user_without_image)
    end

    context 'ユーザーがプロフィール画像を設定している場合' do
      it 'ユーザーに関連するつぶやきは設定されたプロフィール画像を返すこと' do
        tweets_with_image = described_class.tweet_and_image(Tweet.where(user: user_with_image))
        tweets_with_image.each do |data|
          expect(data[:image].filename.to_s).to eq profile_with_image.image.filename.to_s
        end
      end
    end

    context 'ユーザーがプロフィール画像を設定していない場合' do
      it 'ユーザーに関連するつぶやきはデフォルト画像を返すこと' do
        tweets_without_image = described_class.tweet_and_image(Tweet.where(user: user_without_image))
        tweets_without_image.each do |data|
          expect(data[:image]).to eq 'user_default.png'
        end
      end
    end

    context 'プロフィール画像を設定しているユーザーと設定していないユーザーが混在している場合' do
      it '適切な数のツイートにプロフィール画像を返すこと' do
        tweets = described_class.tweet_and_image(Tweet.all)
        count_with_image = tweets.count do |data|
          data[:tweet].user == user_with_image && data[:image].filename.to_s == profile_with_image.image.filename.to_s
        end
        expect(count_with_image).to eq(2)
      end

      it '適切な数のツイートにデフォルト画像を返すこと' do
        tweets = described_class.tweet_and_image(Tweet.all)
        count_without_image = tweets.count do |data|
          data[:tweet].user == user_without_image && data[:image] == 'user_default.png'
        end
        expect(count_without_image).to eq(2)
      end
    end
  end
end
