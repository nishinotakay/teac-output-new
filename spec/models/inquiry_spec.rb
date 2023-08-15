require 'rails_helper'

RSpec.describe Inquiry, type: :model do
  let(:inquiry) { build(:inquiry) }
  context "問い合わせ新規登録で指定文字数以上を入力したらバリデーションが通る" do
    it "件名を30文字以上入力するとバリデーションが通る。" do
      inquiry.subject = Faker::Lorem.characters(number: 31)
      expect(inquiry).to_not be_valid
    end
    it "内容を800文字以上入力するとバリデーションが通る。" do
      inquiry.content = Faker::Lorem.characters(number: 801)
      expect(inquiry).to_not be_valid
    end
  end

  describe '並び替え' do
    before do
      @inquiry1 = FactoryBot.create(:inquiry, :first_inquiry)
      @inquiry2 = FactoryBot.create(:inquiry, :second_inquiry)
      @inquiry3 = FactoryBot.create(:inquiry, :third_inquiry)
    end
    

    context 'order パラメーターが与えられた場合' do
      it 'subjectの昇順でinquiriesを並べ替えます' do
        params = { order: { subject: 'ASC' }, filter: {} }
        expect(Inquiry.apply_sort_and_filter(Inquiry.all, params)).to eq([@inquiry1, @inquiry2, @inquiry3])
      end
      it 'subjectの降順でinquiriesを並べ替えます' do
        params = { order: { subject: 'DESC' }, filter: {} }
        expect(Inquiry.apply_sort_and_filter(Inquiry.all, params)).to eq([@inquiry3, @inquiry2, @inquiry1])
      end
      it 'contentの昇順でinquiriesを並べ替えます' do
        params = { order: { content: 'ASC' }, filter: {} }
        expect(Inquiry.apply_sort_and_filter(Inquiry.all, params)).to eq([@inquiry1, @inquiry2, @inquiry3])
      end
      it 'contentの降順でinquiriesを並べ替えます' do
        params = { order: { content: 'DESC' }, filter: {} }
        expect(Inquiry.apply_sort_and_filter(Inquiry.all, params)).to eq([@inquiry3, @inquiry2, @inquiry1])
      end
      it 'created_atの昇順でinquiriesを並べ替えます' do
        params = { order: { created_at: 'ASC' }, filter: {} }
        expect(Inquiry.apply_sort_and_filter(Inquiry.all, params)).to eq([@inquiry1, @inquiry2, @inquiry3])
      end
      it 'created_atの降順でinquiriesを並べ替えます' do
        params = { order: { created_at: 'DESC' }, filter: {} }
        expect(Inquiry.apply_sort_and_filter(Inquiry.all, params)).to eq([@inquiry3, @inquiry2, @inquiry1])
      end
    end
  end

  describe '表示検索' do
    context 'フィルタhiddenが1の場合' do
      let(:params) { { filter: { hidden: "1" } } }
      let!(:inquiry_visible) { FactoryBot.create(:inquiry, hidden: false) }
      let(:result) { Inquiry.get_inquiries(params) }
      
      it '表示される問い合わせのみを返す' do
        expect(result.first).to include(inquiry_visible)
      end
      
    end
    context 'フィルタhiddenが2の場合' do
      let(:params) { { filter: { hidden: "2" } } }
      let!(:inquiry_hidden) { FactoryBot.create(:inquiry, hidden: true) }
      let(:result) { Inquiry.get_inquiries(params) }
      
      it '表示される問い合わせのみを返す' do
        expect(result.second).to include(inquiry_hidden)
      end
      
    end
    context 'フィルタhiddenが3の場合' do
      let(:params) { { filter: { hidden: "3" } } }
      let!(:inquiry_both) { FactoryBot.create(:inquiry, hidden: [true, false]) }
      let(:result) { Inquiry.get_inquiries(params) }
      
      it '表示される問い合わせのみを返す' do
        expect(result.third).to include(inquiry_both)
      end
      
    end
  end
    
end
