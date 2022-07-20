require 'rails_helper'

RSpec.describe Profile, type: :model do
  # pending "add some examples to (or delete) #{__FILE__}"
  let :profile do
    build(:profile)
  end

  describe 'バリデーションについて' do
    subject do
      profile
    end

    it 'バリデーションが通ること' do
      expect(subject).to be_valid
    end

    describe '#name' do
      context '存在しない場合' do
        before :each do
          subject.name = nil
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('nameを入力してください')
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

      context '文字数が20文字の場合' do
        before :each do
          subject.title = 'a' * 20
        end

        it 'バリデーションが通ること' do
          expect(subject).to be_valid
        end
      end

      context '文字数が21文字の場合' do
        before :each do
          subject.title = 'a' * 21
        end

        it 'バリデーションに落ちること' do
          expect(subject).to be_invalid
        end

        it 'バリデーションのエラーが正しいこと' do
          subject.valid?
          expect(subject.errors.full_messages).to include('nameは20文字以内で入力してください')
        end
      end
    end

    describe '#purpose' do
      context '存在しない場合' do
        before :each do
          subject.purpose = nil

          it 'バリデーションに落ちること' do
            expect(subject).to be_invalid
          end

          it 'バリデーションのエラーが正しいこと' do
            subject.valid?
            expect(subject.errors.full_messages).to include('purposeを入力してください')
          end
        end
      end
    end
  end
end
