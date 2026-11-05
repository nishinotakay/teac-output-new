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

  describe 'テナントの紐付け' do
    it 'tenant が無いと無効になる' do
      course = build(:course, tenant: nil)
      expect(course).not_to be_valid
      expect(course.errors.details[:tenant]).to include(error: :required)
    end

    it 'tenant があれば有効になる' do
      expect(build(:course, tenant: create(:tenant))).to be_valid
    end
  end

  describe 'テナントの default_scope' do
    let(:tenant) { create(:tenant) }
    let!(:own_course) { create(:course, tenant: tenant) }
    let!(:foreign_course) { create(:course, tenant: create(:tenant)) }

    after { Current.reset }

    it 'Current.tenant をセットすると自テナントのコースだけ見える' do
      Current.tenant = tenant
      expect(described_class.all).to contain_exactly(own_course)
    end

    it 'Current.tenant をセットすると他テナントのコースは find できない' do
      Current.tenant = tenant
      expect { described_class.find(foreign_course.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'Current.tenant が nil なら全テナントのコースが見える' do
      Current.tenant = nil
      expect(described_class.all).to contain_exactly(own_course, foreign_course)
    end
  end

  describe 'Tenant の削除' do
    it 'コースがあるテナントは destroy できず、コースも残る' do
      tenant = create(:tenant)
      course = create(:course, tenant: tenant)
      expect(tenant.destroy).to be(false)
      expect(tenant.errors.details[:base].pluck(:error)).to include(:'restrict_dependent_destroy.has_many')
      expect(Tenant.exists?(tenant.id)).to be(true)
      expect(described_class.unscoped.exists?(course.id)).to be(true)
    end

    it 'コースが無いテナントは destroy できる' do
      tenant = create(:tenant)
      expect(tenant.destroy).to be_truthy
    end
  end
end
