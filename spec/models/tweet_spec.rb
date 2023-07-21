require 'rails_helper'

RSpec.describe Tweet, type: :model do
  let(:user) { FactoryBot.create(:user, :a) }

  describe 'validation' do
    # postがあれば有効な状態であること
    it 'is valid with a post' do
      tweet = FactoryBot.create(:tweet, user: user)
      expect(tweet).to be_valid
    end

    # postがなければ無効な状態であること
    it 'is invalid without a post' do
      tweet = FactoryBot.build(:tweet, post: nil, user: user)
      tweet.valid?
      expect(tweet.errors[:post]).to include('を入力してください')
    end

    # postが255文字以内の場合は有効な状態であること
    it 'is valid if the post has 255 characters or fewer' do
      tweet = FactoryBot.build(:tweet, post: 'a' * 255, user: user)
      expect(tweet).to be_valid
    end

    # postが256文字以上の場合は無効な状態であること
    it 'is invalid if the post has 256 characters or more' do
      tweet = FactoryBot.build(:tweet, post: 'a' * 256, user: user)
      tweet.valid?
      expect(tweet.errors[:post]).to include('は255文字以内で入力してください')
    end
  end

  describe 'association' do
    # tweetオブジェクト作成時にuserと関連付けられること
    it 'is associated with a user when created ' do
      tweet = FactoryBot.create(:tweet, user: user)
      expect(tweet.user).to eq(user)
    end

    # userが存在しない場合、tweetオブジェクトを作成できない
    it 'cannot be created without a user' do
      tweet_without_user = FactoryBot.build(:tweet, user: nil)
      expect(tweet_without_user).not_to(be_valid)
    end

    # tweetオブジェクトが多数のtweet_commentを持つこと
    it 'has many tweet comments' do
      tweet = FactoryBot.create(:tweet, user: user)
      tweet_comment1 = FactoryBot.create(:tweet_comment, tweet: tweet)
      tweet_comment2 = FactoryBot.create(:tweet_comment, tweet: tweet)
      tweet_comment3 = FactoryBot.create(:tweet_comment, tweet: tweet)
      expect(tweet.tweet_comments).to eq([tweet_comment1, tweet_comment2, tweet_comment3])
    end

    # tweetオブジェクト削除時に関連づけられたtweet_commentsが削除されること
    it 'deletes associated tweet comments when the tweet is destryed' do
      tweet = FactoryBot.create(:tweet, user: user)
      FactoryBot.create_list(:tweet_comment, 3, tweet: tweet)
      expect { tweet.destroy }.to change { TweetComment.count }.by(-3)
    end
  end
end
