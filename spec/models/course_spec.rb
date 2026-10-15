require 'rails_helper'

RSpec.describe Course, type: :model do
  describe 'コース名の長さ' do
    it '255文字なら有効になる' do
      expect(build(:course, name: 'あ' * 255)).to be_valid
    end

    it '256文字なら無効になる' do
      course = build(:course, name: 'あ' * 256)
      expect(course).not_to be_valid
      expect(course.errors.details[:name]).to include(error: :too_long, count: 255)
    end
  end

  describe 'コース名の入力必須' do
    it '名前があれば有効になる' do
      expect(build(:course, name: 'Ruby入門')).to be_valid
    end

    [nil, '', '   '].each do |name|
      it "名前が#{name.inspect}なら無効になる" do
        course = build(:course, name: name)
        expect(course).not_to be_valid
        expect(course.errors.details[:name]).to include(error: :blank)
      end
    end
  end
end
