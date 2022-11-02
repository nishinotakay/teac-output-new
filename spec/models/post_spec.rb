require 'rails_helper'

RSpec.describe Post, type: :model do

  before do
    # 成功した場合のpostデータを定義
    @post = build(:post, title: "Rspecテスト集", body: "Rspecに関する解説動画", youtube_url: "youtube.com/watch?v=qpiKb0mdbr0&t=496s")
  end

  # describeでテスト対象をグループ分け
  describe 'モデルのテスト' do
    # contextでどのような状況なのかをグループ分け
    context '新規登録できるとき' do
      it "全ての項目が正しく入力されていれば登録できる" do
        # 上記のbefore_actionで作った有効な場合のデータが正しいかを確認。
        expect(@post).to be_valid
      end
    end

    context "空白のバリデーションチェック" do
      it "titleが空白の場合にエラーメッセージが返ってくるか" do
        # postにtitleカラムを空で保存したものを代入
        post = build(:post, title: nil)
        # バリデーションチェックを行う
        post.valid?
        # titleカラムでエラーが出て、エラーメッセージに"を入力してください"が含まれているか？
        expect(post.errors[:title]).to include("を入力してください")
      end

      it "bodyが空白の場合にエラーメッセージが返ってくるか" do
        # postにbodyカラムを空で保存したものを代入
        post = build(:post, body: nil)
        # バリデーションチェックを行う
        post.valid?
        # bodyカラムでエラーが出て、エラーメッセージに"を入力してください"が含まれているか？
        expect(post.errors[:body]).to include("を入力してください")
      end

      it "Youtubeが空白の場合にエラーメッセージが返ってくるか" do
        # postにyoutube_urlカラムを空で保存したものを代入
        post = build(:post, youtube_url: nil)
        # バリデーションチェックを行う
        post.valid?
        # youtube_urlカラムでエラーが出て、エラーメッセージに"を入力してください"が含まれているか？
        expect(post.errors[:youtube_url]).to include("を入力してください")
      end
    end

    context "文字制限のバリデーションチェック" do
      it "titleの文字数が30文字以上の場合エラーメッセージが返ってくるか" do
        post = build(:post)
        # Faker::Lorem.characters(number: 31)でランダムな文字列を31字で作成できる
        post.title = Faker::Lorem.characters(number: 31)
        post.valid?
        expect(post.errors[:title]).to include("は30文字以内で入力してください")
      end

      it "bodyの文字数が241文字以上の場合エラーメッセージが返ってくるか" do
        post = build(:post)
        # Faker::Lorem.characters(number: 241)でランダムな文字列を241字で作成できる
        post.body = Faker::Lorem.characters(number: 241)
        post.valid?
        expect(post.errors[:body]).to include("は240文字以内で入力してください")
      end
    end

    describe 'アソシエーションのテスト' do
      context 'Userモデルとの関係' do
        it '多:1となっている' do
          expect(Post.reflect_on_association(:user).macro).to eq :belongs_to
        end
      end
    end
  end
end
