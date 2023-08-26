require 'rails_helper'

RSpec.describe Inquiry, type: :model do
  describe '新規登録' do
    let(:inquiry) { build(:inquiry) }
    context "問い合わせ新規登録で指定文字数以下を入力したら場合" do
      it "件名を30文字以下で入力するとバリデーションが通る。" do
        inquiry.subject = Faker::Lorem.characters(number: 30)
        expect(inquiry).to be_valid
      end
      it "内容を800文字以下で入力するとバリデーションが通る。" do
        inquiry.content = Faker::Lorem.characters(number: 800)
        expect(inquiry).to be_valid
      end
    end
    context "問い合わせ新規登録で指定文字数以上を入力した場合" do
      it "件名を30文字以上入力するとバリデーションが通らない。" do
        inquiry.subject = Faker::Lorem.characters(number: 31)
        expect(inquiry).to_not be_valid
      end
      it "内容を800文字以上入力するとバリデーションが通らない。" do
        inquiry.content = Faker::Lorem.characters(number: 801)
        expect(inquiry).to_not be_valid
      end
    end
  end

  describe '並び替え' do
    before do
      @inquiry1 = FactoryBot.create(:inquiry, :first_inquiry)
      @inquiry2 = FactoryBot.create(:inquiry, :second_inquiry)
      @inquiry3 = FactoryBot.create(:inquiry, :third_inquiry)
    end

    subject { Inquiry.apply_sort_and_filter(Inquiry.all, params) }

    context '件名の並び替えをする時' do
      context '五十音順(ASC)の場合' do
        let(:params) { { order: { subject: 'ASC' }, filter: {} } }
        it '昇順になる' do
          is_expected.to eq([@inquiry1, @inquiry2, @inquiry3])
        end
      end
    end
    context '逆順(DESC)の場合' do
      let(:params) { { order: { subject: 'DESC' }, filter: {} } }
      it '降順になる' do
        is_expected.to eq([@inquiry3, @inquiry2, @inquiry1])
      end
    end

    context '内容の並び替えをする時。' do
      context '五十音順(ASC)の場合' do
        let(:params) { { order: { content: 'ASC' }, filter: {} } }
        it '昇順になる' do
          is_expected.to eq([@inquiry1, @inquiry2, @inquiry3])
        end
      end
      context '逆順(DESC)の場合' do
        let(:params) { { order: { content: 'DESC' }, filter: {} } }
        it '降順になる' do
          is_expected.to eq([@inquiry3, @inquiry2, @inquiry1])
        end
      end
    end
    context '作成日時の並び替えをする時。' do
      context '五十音順(ASC)の場合' do
        let(:params) { { order: { created_at: 'ASC' }, filter: {} } }
        it '昇順になる' do
          is_expected.to eq([@inquiry1, @inquiry2, @inquiry3])
        end
      end
      context '逆順(DESC)の場合' do
        let(:params) { { order: { created_at: 'DESC' }, filter: {} } }
        it '降順になる' do
          is_expected.to eq([@inquiry3, @inquiry2, @inquiry1])
        end
      end
    end
  end

  describe '検索機能の表示切り替え' do
    context '表示を選択する' do
      let(:params) { { filter: { hidden: "1" } } }
      let!(:inquiry_visible) { FactoryBot.create(:inquiry, hidden: false) }
      let(:result) { Inquiry.get_inquiries(params) }
      it '表示のみ検索される' do
        expect(result.first).to include(inquiry_visible)
      end
    end
    context '非表示を選択する' do
      let(:params) { { filter: { hidden: "2" } } }
      let!(:inquiry_hidden) { FactoryBot.create(:inquiry, hidden: true) }
      let(:result) { Inquiry.get_inquiries(params) }
      it '非表示のみ検索される' do
        expect(result.second).to include(inquiry_hidden)
      end
    end
    context '全表示を選択する' do
      let(:params) { { filter: { hidden: "3" } } }
      let!(:inquiry_both) { FactoryBot.create(:inquiry, hidden: [true, false]) }
      let(:result) { Inquiry.get_inquiries(params) }
      it '全表示検索される' do
        expect(result.third).to include(inquiry_both)
      end
      
    end

  
    describe "検索機能" do
      before do
        @inquiry1 = FactoryBot.create(:inquiry, subject: "テスト問い合わせ1", content: "問い合わせ1の内容", created_at: "2022-08-01")
        @inquiry2 = FactoryBot.create(:inquiry, subject: "テスト問い合わせ2", content: "問い合わせ2の特定の内容", created_at: "2022-08-01")
        @inquiry3 = FactoryBot.create(:inquiry, subject: "異なる問い合わせ", content: "問い合わせ3", created_at: "2022-08-03")
      end
      context "部分検索" do
        it "一致する件名の問い合わせを抽出する" do
          result = Inquiry.apply_sort_and_filter(Inquiry.all, { order: "created_at ASC", filter: { subject: "テスト" } })
          expect(result).to contain_exactly(@inquiry1, @inquiry2)
        end
        it "一致する内容の問い合わせを抽出する" do
          result = Inquiry.apply_sort_and_filter(Inquiry.all, { order: "created_at ASC", filter: { content: "内容" } })
          expect(result).to contain_exactly(@inquiry1, @inquiry2)
        end
        it "特定の日付に作成された問い合わせを抽出する" do
          result = Inquiry.apply_sort_and_filter(Inquiry.all, { order: "created_at ASC", filter: { created_at: "2022-08-01" } })
          expect(result).to contain_exactly(@inquiry1, @inquiry2)
        end
      end
    end    
  end
    
end
