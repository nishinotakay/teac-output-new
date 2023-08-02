require 'rails_helper'

RSpec.shared_examples '正常な記事投稿について' do # RSpecの記述無しでも可
  it 'バリデーションが通ること' do
    expect(article).to be_valid
  end
end

RSpec.shared_examples 'タイトルについて' do
  context '未入力の場合' do
    before :each do # itの前に実行
      article.title = nil
    end

    it 'バリデーションに落ちること' do
      expect(article).to be_invalid
    end

    it 'バリデーションのエラーが正しいこと' do
      article.valid?
      expect(article.errors.full_messages).to include('タイトルを入力してください')
    end
  end

  context '文字数が40文字の場合' do
    before :each do
      article.title = 'a' * 40
    end

    it 'バリデーションが通ること' do
      expect(article).to be_valid
    end
  end

  context '文字数が41文字の場合' do
    before :each do
      article.title = 'a' * 41
    end

    it 'バリデーションに落ちること' do
      expect(article).to be_invalid
    end

    it 'バリデーションのエラーが正しいこと' do
      article.valid?
      expect(article.errors.full_messages).to include('タイトルは40文字以内で入力してください')
    end
  end
end

RSpec.shared_examples 'サブタイトルについて' do
  context '未入力の場合' do
    before :each do
      article.sub_title = nil
    end

    it 'バリデーションが通ること' do
      expect(article).to be_valid
    end
  end

  context '文字数が50文字の場合' do
    before :each do
      article.sub_title = 'a' * 50
    end

    it 'バリデーションが通ること' do
      expect(article).to be_valid
    end
  end

  context '文字数が51文字の場合' do
    before :each do
      article.sub_title = 'a' * 51
    end

    it 'バリデーションに落ちること' do
      expect(article).to be_invalid
    end

    it 'バリデーションのエラーが正しいこと' do
      article.valid?
      expect(article.errors.full_messages).to include('サブタイトルは50文字以内で入力してください')
    end
  end
end

RSpec.shared_examples '本文について' do
  context '未入力の場合' do
    before :each do
      article.content = nil
    end

    it 'バリデーションに落ちること' do
      expect(article).to be_invalid
    end

    it 'バリデーションのエラーが正しいこと' do
      article.valid?
      expect(article.errors.full_messages).to include('本文を入力してください')
    end
  end
end

RSpec.shared_examples 'アソシエーションについて' do
  context 'ユーザーidが設定されている場合' do
    before :each do
      article.user_id = 1
      article.admin_id = nil
    end

    it '記事が有効であること' do
      expect(article).to be_valid
    end
  end

  context '管理者idが設定されている場合' do
    before :each do
      article.user_id = nil
      article.admin_id = 1
    end

    it '記事が有効であること' do
      expect(article).to be_valid
    end
  end
  context '投稿者のidがない場合' do
    before :each do
      article.user_id = nil
      article.admin_id = nil
    end

    it 'バリデーションに落ちること' do
      expect(article).to be_invalid
    end

    it 'バリデーションのエラーが正しいこと' do
      article.valid?
      expect(article.errors.full_messages).to include("Userを入力してください", "Adminを入力してください")
    end
  end
end
