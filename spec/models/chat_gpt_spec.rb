# spec/models/chat_gpt_spec.rb

require 'rails_helper'

RSpec.describe ChatGpt, type: :model do
  describe 'ChatGptモデルのバリデーション' do
    let(:user) { create(:user) }  # userを事前に作成

    describe '正常系' do
      it '質問とモードが正しく入力されていれば、問題なく保存される' do
        chat_gpt = described_class.new(prompt: 'AIについて教えてください', mode: 'teacher', user: user)
        expect(chat_gpt).to be_valid
      end
    end

    describe '異常系' do
      it '質問が未入力の場合、バリデーションエラーが発生する' do
        chat_gpt = described_class.new(prompt: nil, mode: 'teacher', user: user)
        expect(chat_gpt).not_to be_valid
        expect(chat_gpt.errors[:prompt]).to include('を入力してください')
      end

      it 'モードが許可されていない値の場合、バリデーションエラーが発生する' do
        chat_gpt = described_class.new(prompt: 'AIについて教えてください', mode: 'invalid_mode', user: user)
        expect(chat_gpt).not_to be_valid
        expect(chat_gpt.errors[:mode]).to include('は一覧にありません')
      end
    end
  end
end
