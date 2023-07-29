require 'rails_helper'

RSpec.describe Tweet, type: :model do

  before do
    @user = User.create(name: 'test_user1', email: 'test1@email.com', password: 'password')
    @user2 = User.create(name: 'test_user2', email: 'test2@email.com', password: 'password')
    @user3 = User.create(name: 'test_user3', email: 'test3@email.com', password: 'password')
    @tweet = Tweet.create(post: 'test_content', user_id: @user.id)
  end

  describe 'validation' do
    # 有効な投稿が存在する場
    context 'when valid post is present' do
      # バリデーションをパスする
      it 'passes the validation' do
        expect(@tweet.valid?).to eq(true)
      end
    end

    # 投稿が入力されていない場合
    context 'when the post is not provided' do
      # バリデーションをパスしない
      it 'does not pass the validation' do
        @tweet.post = nil
        expect(@tweet.valid?).to eq(false)
      end
    end

    # 投稿フォームに255文字以内で入力されている場合
    context 'when the post is within 255 characters' do
      # バリデーションをパスする
      it 'passes the validation' do
        @tweet.post = 'c' * 255
        expect(@tweet.valid?).to eq(true)
      end
    end

    # 投稿フォームに255文字より多く入力されている場合
    context 'when the post is more than 255 characters' do
      # バリデーションをパスしない
      it 'does not pass the validation' do
        @tweet.post = 'c' * 256
        expect(@tweet.valid?).to eq(false)
      end
    end

    # 5以上の画像データをアップロードする場合
    context 'when more than 4 images are uploaded' do
      # バリデーションをパスしない
      it 'does not pass the valication' do
        5.times do |i|
          @tweet.images.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', "test#{i + 1}.png")),
          filename: "test#{i + 1}.png", content_type: 'image/png')
        end
        expect(@tweet.valid?).to eq(false)
      end
    end

    # 4以内の画像データをアップロードする場合
    context 'when uploading up to 4 images' do
      it 'is valid because there are up to 4 uploaded images' do
        4.times do |i|
          @tweet.images.attach(io: File.open(Rails.root.join('spec', 'fixtures', 'files', "test#{i + 1}.png")),
          filename: "test#{i + 1}.png", content_type: 'image/png')
        end
        expect(@tweet.valid?).to eq(true)
      end
    end

    # 5MB以下の画像データをアップロードする場合
    context 'when uploading an image data up to 5MB' do
      # バリデーションをパスする
      it 'is valid because the image is up to 5MB' do
        skip
        file_path = Rails.root.join('spec', 'fixtures', 'files', 'test5mb.png')
        File.open(file_path, 'w+') do |f|
          f.write('0' * 5.megabytes)
          f.rewind
          @tweet.images.attach(io: f, filename: "test5mb.png", content_type: 'image/png')
        end
        expect(@tweet.valid?).to eq(true)
        expect(@tweet.errors.full_messages).to be_empty
        File.delete(file_path) if File.exist?(file_path)
      end
    end

    # jpeg形式、png形式以外のファイルをアップロードする場合
    context 'when uploading a file that is not in jpeg or png format' do
      # バリデーションをパスしない
      it 'is invalid because the format of uploaded file is not jpeg or png' do
        skip
        file_path = Rails.root.join('spec', 'fixtures', 'files', 'test_csv.csv')
        File.open(file_path, 'w+') do |f|
          f.write('0' * 1000.bytes)
          f.rewind
          @tweet.images.attach(io: f, filename: 'test_csv.csv', content_type: 'text/csv')
        end
        expect(@tweet.valid?).to eq(false)
        expect(@tweet.errors.full_messages).to include('Imagesはpng形式またはjpeg形式でアップロードして下さい。')
        File.delete(file_path) if File.exist?(file_path)
      end
    end

    # jpeg形式、png形式のファイルをアップロードする場合
    context 'when uploading a file that is in jpeg or png format' do
      # バリデーションをパスする
      it 'is valid because the format of uploaded file is jpeg or png' do
        skip
        @tweet.images.attach(io: Rails.root.join('spec', 'fixtures', 'files', 'test.jpeg'),
        filename: 'test.jpeg', content_type: 'image/jpeg')
        expect(@tweet.valid?).to eq(true)
        expect(@tweet.errors.full_messages).to be_empty
      end
    end

  end

  describe 'association' do
    # tweetオブジェクト作成時にuserと関連付けられること
    it 'is associated with a user when created ' do
      expect(@tweet.user_id).to eq(@user.id)
    end

    # userが存在しない場合、tweetオブジェクトを作成できない
    it 'cannot be created without a user' do
      @tweet.user_id = nil
      expect(@tweet).not_to(be_valid)
    end

    # tweetオブジェクトが多数のtweet_commentを持つこと
    it 'has many tweet comments' do
      tweet_comment1 = @tweet.tweet_comments.create(content: 'test_tweet_content1', user_id: @user.id, recipient_id: @tweet.user_id)
      tweet_comment2 = @tweet.tweet_comments.create(content: 'test_tweet_content2', user_id: @user2.id, recipient_id: @tweet.user_id)
      tweet_comment3 = @tweet.tweet_comments.create(content: 'test_tweet_content3', user_id: @user3.id, recipient_id: @tweet.user_id)
      expect(@tweet.tweet_comments).to match_array([tweet_comment1, tweet_comment2, tweet_comment3])
    end

    # tweetオブジェクト削除時に関連づけられたtweet_commentsが削除されること
    it 'deletes associated tweet comments when the tweet is destryed' do
      3.times do
        @tweet.tweet_comments.create(content: 'test_tweet_content', user_id: @user.id, recipient_id: @tweet.user_id)
      end
      expect { @tweet.destroy }.to change { TweetComment.count }.by(-3)
    end
  end
end
