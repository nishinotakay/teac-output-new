require 'rails_helper'

RSpec.describe Tweet, type: :model do
  # let(:user) { FactoryBot.create(:user, :a) }
  before do
    @user = User.create(name: 'test_user1', email: 'test1@email.com', password: 'password')
    @user2 = User.create(name: 'test_user2', email: 'test2@email.com', password: 'password')
    @user3 = User.create(name: 'test_user3', email: 'test3@email.com', password: 'password')
    @tweet = Tweet.create(post: 'test_content', user_id: @user.id)

  end

  describe 'validation' do
    # 有効な投稿が存在する場合
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
    context 'when the post is less than 255 characters' do
      # バリデーションをパスする
      it 'passes the validation' do
        @tweet.post = 'c' * 255
        expect(@tweet.valid?).to eq(true)
      end
    end

    # 投稿フォームに255文字以内で入力されている場合
    context 'when the post is more than 256 characters' do
      # バリデーションをパスしない
      it 'does not pass the validation' do
        @tweet.post = 'c' * 256
        expect(@tweet.valid?).to eq(false)
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
      tweet_comment2 = @tweet.tweet_comments.create(content: 'test_tweet_content2', user_id: @user.id, recipient_id: @tweet.user_id)
      tweet_comment3 = @tweet.tweet_comments.create(content: 'test_tweet_content3', user_id: @user.id, recipient_id: @tweet.user_id)
      expect(@tweet.tweet_comments).to eq([tweet_comment1, tweet_comment2, tweet_comment3])

      # tweet = FactoryBot.create(:tweet, user: user)
      # tweet_comment1 = FactoryBot.create(:tweet_comment, tweet: tweet)
      # tweet_comment2 = FactoryBot.create(:tweet_comment, tweet: tweet)
      # tweet_comment3 = FactoryBot.create(:tweet_comment, tweet: tweet)
      # expect(tweet.tweet_comments).to eq([tweet_comment1, tweet_comment2, tweet_comment3])
    end

    # tweetオブジェクト削除時に関連づけられたtweet_commentsが削除されること
    it 'deletes associated tweet comments when the tweet is destryed' do
      3.times do
        @tweet.tweet_comments.create(content: 'test_tweet_content', user_id: @user.id, recipient_id: @tweet.user_id)
      end
      # tweet = FactoryBot.create(:tweet, user: user)
      # FactoryBot.create_list(:tweet_comment, 3, tweet: tweet)
      expect { @tweet.destroy }.to change { TweetComment.count }.by(-3)
    end
  end
end
