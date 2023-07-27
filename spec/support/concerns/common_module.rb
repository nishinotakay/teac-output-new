require 'rails_helper'

RSpec.shared_examples '正常な記事投稿について' do # RSpecの記述無しでも可
  it 'バリデーションが通ること' do
    expect(subject).to be_valid
  end
end

RSpec.shared_examples 'タイトルについて' do
  context '未入力の場合' do
    before :each do # itの前に実行
      subject.title = nil
    end

    it 'バリデーションに落ちること' do
      expect(subject).to be_invalid
    end

    it 'バリデーションのエラーが正しいこと' do
      subject.valid?
      expect(subject.errors.full_messages).to include('タイトルを入力してください')
    end
  end

  context '文字数が40文字の場合' do
    before :each do
      subject.title = 'a' * 40
    end

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end
  end

  context '文字数が41文字の場合' do
    before :each do
      subject.title = 'a' * 41
    end

    it 'バリデーションに落ちること' do
      expect(subject).to be_invalid
    end

    it 'バリデーションのエラーが正しいこと' do
      subject.valid?
      expect(subject.errors.full_messages).to include('タイトルは40文字以内で入力してください')
    end
  end
end

RSpec.shared_examples 'サブタイトルについて' do
  context '未入力の場合' do
    before :each do
      subject.sub_title = nil
    end

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end
  end

  context '文字数が50文字の場合' do
    before :each do
      subject.sub_title = 'a' * 50
    end

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end
  end

  context '文字数が51文字の場合' do
    before :each do
      subject.sub_title = 'a' * 51
    end

    it 'バリデーションに落ちること' do
      expect(subject).to be_invalid
    end

    it 'バリデーションのエラーが正しいこと' do
      subject.valid?
      expect(subject.errors.full_messages).to include('サブタイトルは50文字以内で入力してください')
    end
  end
end

RSpec.shared_examples '本文について' do
  context '未入力の場合' do
    before :each do
      subject.content = nil
    end

    it 'バリデーションに落ちること' do
      expect(subject).to be_invalid
    end

    it 'バリデーションのエラーが正しいこと' do
      subject.valid?
      expect(subject.errors.full_messages).to include('本文を入力してください')
    end
  end
end
