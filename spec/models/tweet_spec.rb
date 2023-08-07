require 'rails_helper'

RSpec.describe Tweet, type: :model do
  let(:user) { create(:user, name:'山田太郎', email: Faker::Internet.email, password: 'password') }
  let(:tweet) { create(:tweet, post: "it's sunny day!", user: user) }
  let(:tweet_comment) { FactoryBot.create_list(:tweet_comment, 3, user: user, tweet: tweet, recipient_id: tweet.user_id)}
  describe 'validation' do
    before do
      tweet
    end
    
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
        expect(tweet.errors.full_messages.any? { |m| m.include?('Post') } ).to eq(true)
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
        expect(tweet.errors.full_messages.any? { |m| m.include?('Post') } ).to eq(true)
      end
    end

    context '4よりも多いの画像データをアップロードする場合' do
      it 'バリデーションをパスしない' do
        5.times do |i|
          tweet.images.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', "test#{i + 1}.png")),
          filename: "test#{i + 1}.png", content_type: 'image/png')
        end
        expect(tweet.valid?).not_to eq(true)
        expect(tweet.errors.full_messages.any? { |m| m.include?('Image') } ).to eq(true)
      end
    end

    context '4以内の画像データをアップロードする場合' do
      it 'バリデーションをパスする。' do
        4.times do |i|
          tweet.images.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', "test#{i + 1}.png")),
          filename: "test#{i + 1}.png", content_type: 'image/png')
        end
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context '5MB以下の画像データをアップロードする場合' do
      it 'バリデーションをパスする' do
        file = StringIO.new('0' * 5.megabytes)
        tweet.images.attach(io: file, filename: "test5mb.png", content_type: 'image/png')
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context '5MBよりも大きな画像データをアップロードする場合' do      
      it 'バリデーションをパスしない' do
        file = StringIO.new('0' * 6.megabytes)
        tweet.images.attach(io: file, filename: "test6mb.png", content_type: 'image/png')
        expect(tweet.valid?).not_to eq(true)
        expect(tweet.errors.full_messages.any? { |m| m.include?('Image') } ).to eq(true)
      end
    end

    context 'jpeg形式、png形式以外のファイルをアップロードする場合' do
      it 'バリデーションをパスしない' do
        file = StringIO.new('0' * 10.bytes)
        tweet.images.attach(io: file, filename: 'test_csv.csv', content_type: 'text/csv')
        expect(tweet.valid?).not_to eq(true)
        expect(tweet.errors.full_messages.any? { |m| m.include?('Image') } ).to eq(true)
      end
    end

    shared_examples 'jpeg、jpg、pngのファイルをアップロードする場合' do |filename, content_type|
      it "#{content_type}はバリデーションをパスする" do
        file = StringIO.new('0' * 10.kilobytes)
        tweet.images.attach(io: file, filename: filename, content_type: content_type)
        expect(tweet.valid?).to eq(true)
        expect(tweet.errors).to be_empty
      end
    end

    context 'jpegファイルをアップロードする場合' do
      it_behaves_like 'jpeg、jpg、pngのファイルをアップロードする場合', 'test.jpeg', 'image/jpeg'
    end

    context 'jpgファイルをアップロードする場合' do
      it_behaves_like 'jpeg、jpg、pngのファイルをアップロードする場合', 'test.jpg', 'image/jpeg'
    end

    context 'pngファイルをアップロードする場合' do
      it_behaves_like 'jpeg、jpg、pngのファイルをアップロードする場合', 'test.png', 'image/png'
    end

  end

  describe 'association' do
    before do
      tweet
      tweet_comment
    end

    context 'tweetが存在する場合' do
       it 'userと関連付けられる' do
        expect(tweet.user_id).to eq(user.id)
      end
    end

    context '複数のtweet_commentが存在する場合' do
      context 'tweetを削除する場合' do
        it '3つの関連付けられたtweet_commentsが削除される' do
          expect { tweet.destroy }.to change { TweetComment.count }.by(-3)
        end
      end
    end
  end
end
