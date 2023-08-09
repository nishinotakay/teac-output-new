require 'rails_helper'

RSpec.describe Tweet, type: :model do
  let(:user) { create(:user, name:'山田太郎', email: Faker::Internet.email, password: 'password') }
  let(:tweet) { create(:tweet, post: "it's sunny day!", user: user) }
  let(:tweet_comment) { FactoryBot.create_list(:tweet_comment, 3, user: user, tweet: tweet, recipient_id: tweet.user_id)}
  describe 'validation' do

    context '有効な投稿が存在する場合' do
      it 'バリデーションをパスする' do
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context '投稿が入力されていない場合' do
      it 'バリデーションをパスしない' do
        tweet.post = nil
        expect(tweet.valid?).not_to eq(true)
        expect(tweet.errors.full_messages).to eq(["Postを入力してください"])
      end
    end

    context '投稿フォームに255文字以内で入力されている場合' do
      it 'バリデーションをパスする' do
        tweet.post = 'c' * 255
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context '投稿フォームに255文字より多く入力されている場合' do
      it 'バリデーションをパスしない' do
        tweet.post = 'c' * 256
        expect(tweet.valid?).not_to eq(true)
        expect(tweet.errors.full_messages).to eq(["Postは255文字以内で入力してください"])
      end
    end

    context '4つよりも多いの画像データをアップロードする場合' do
      it 'バリデーションをパスしない' do
        5.times do |i|
          tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', "test#{i + 1}.png"), 
          filename: "test#{i + 1}.png", content_type: 'image/png'))
        end
        expect(tweet.valid?).not_to eq(true)
        expect(tweet.errors.full_messages).to eq(["Imagesは4つまでしかアップロードできません。"])
      end
    end

    context '4以内の画像データをアップロードする場合' do
      it 'バリデーションをパスする。' do
        4.times do |i|
          tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', "test#{i + 1}.png"),
          filename: "test#{i + 1}.png", content_type: 'image/png'))
        end
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context '5MB以下の画像データをアップロードする場合' do
      it 'バリデーションをパスする' do
        tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_5mb.jpg'), filename: "test5mb.jng", content_type: 'image/jpeg'))
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context '5MBよりも大きな画像データをアップロードする場合' do
      it 'バリデーションをパスしない' do
        tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_6mb.jpg'), filename: "test6mb.jng", content_type: 'image/jpeg'))
        expect(tweet.valid?).not_to eq(true)
        expect(tweet.errors.full_messages).to eq(["Imagesは1つのファイル5MB以内にして下さい。"])
      end
    end

    context 'jpeg形式、png形式以外のファイルをアップロードする場合' do
      it 'バリデーションをパスしない' do
        tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', 'test_csv.csv'), filename: 'test_csv.csv', content_type: 'text/csv'))
        expect(tweet.valid?).not_to eq(true)
        expect(tweet.errors.full_messages).to eq(["Imagesはpng形式またはjpeg形式でアップロードして下さい。"])
      end
    end

    shared_examples 'jpeg、jpg、pngのファイルをアップロードする場合' do |filename, content_type|
      it "#{content_type}はバリデーションをパスする" do
        tweet.images.attach(fixture_file_upload(Rails.root.join('spec', 'fixtures', 'files', filename), filename: filename, content_type: content_type))
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

  # describe 'association' do
  #   before do
  #     tweet
  #     tweet_comment
  #   end

  #   context 'tweetが存在する場合' do
  #      it 'userと関連付けられる' do
  #       expect(tweet.user_id).to eq(user.id)
  #     end
  #   end

  #   context '複数のtweet_commentが存在する場合' do
  #     before do
  #       tweet_comment
  #     end
  #     context 'tweetを削除する場合' do
  #       it '3つの関連付けられたtweet_commentsが削除される' do
  #         expect { tweet.destroy }.to change { TweetComment.count }.by(-3)
  #       end
  #     end
  #   end
  # end
end
