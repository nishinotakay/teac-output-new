require 'rails_helper'

RSpec.describe Category, type: :model do
  around do |example|
    Current.reset
    example.run
  ensure
    Current.reset
  end

  it 'カテゴリーをDBに保存して読み直せる' do
    tenant = Tenant.create!(name: 'テストテナント')
    course = tenant.courses.create!(name: 'テストコース')

    category = course.categories.create!(
      name: '基本文法',
      tenant: tenant
    )

    saved_category = Category.find(category.id)

    expect(saved_category.name).to eq('基本文法')
    expect(saved_category.course_id).to eq(course.id)
    expect(saved_category.tenant_id).to eq(tenant.id)
  end
  describe 'カテゴリー名の検証' do
    let(:tenant) { create(:tenant) }
    let(:course) { create(:course, tenant: tenant) }
    subject(:category) { build(:category, course: course, tenant: tenant, name: category_name) }

    [nil, '', '   ', 'あ' * 256].each do |invalid_name|
      context "名前が#{invalid_name&.length == 256 ? '256文字' : invalid_name.inspect}の場合" do
        let(:category_name) { invalid_name }

        it '保存せず、名前のエラーを返す' do
          expect { expect(category.save).to eq(false) }.not_to change(Category, :count)
          expect(category.errors[:name]).not_to be_empty
        end
      end
    end

    context '名前が255文字の場合' do
      let(:category_name) { 'あ' * 255 }

      it '保存して読み直せる' do
        category.save!
        expect(category.reload.name).to eq(category_name)
      end
    end

    context '名前の前後に空白がある場合' do
      let(:category_name) { '  基本文法  ' }

      it '前後の空白を除去して保存する' do
        category.save!
        expect(category.reload.name).to eq('基本文法')
      end
    end
  end
end
