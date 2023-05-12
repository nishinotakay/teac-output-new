# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:user_a) { build(:user, :a, confirmed_at: Date.today) }
  let(:article) { build(:article, user: user_a) }

  describe 'バリデーションについて' do
    subject do
      article
    end

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end

    describe '#title' do
      context '存在しない場合' do
        before :each do
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

      context '文字数が1文字の場合' do
        before :each do
          subject.title = 'a' * 1
        end

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
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

    describe '#sub_title' do
      context '存在しない場合' do
        before :each do
          subject.sub_title = nil
        end

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
        end
      end

      context '文字数が1文字の場合' do
        before :each do
          subject.sub_title = 'a' * 1
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

    describe '#content' do
      context '存在しない場合' do
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
  end
end
