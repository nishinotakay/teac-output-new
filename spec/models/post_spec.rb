require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:tenant) { create(:tenant) }
  let(:other_tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:admin) { create(:admin, tenant: tenant) }

  def build_post_attributes
    { title: 'タイトル', body: '本文', youtube_url: 'https://www.youtube.com/watch?v=v-Mb2voyTbc' }
  end

  describe 'tenant の付与' do
    it '受講生の投稿は user のテナントが入る' do
      post = described_class.create!(build_post_attributes.merge(user: user))

      expect(post.tenant).to eq(tenant)
    end

    it 'user と admin の両方がある場合は user のテナントを優先する' do
      other_admin = create(:admin, tenant: other_tenant)
      post = described_class.create!(build_post_attributes.merge(user: user, admin: other_admin))

      expect(post.tenant).to eq(tenant)
    end

    it 'user が無く admin だけの場合は admin のテナントが入る' do
      post = described_class.create!(build_post_attributes.merge(admin: admin))

      expect(post.tenant).to eq(tenant)
    end

    it '明示した tenant は上書きしない' do
      post = described_class.create!(build_post_attributes.merge(user: user, tenant: other_tenant))

      expect(post.tenant).to eq(other_tenant)
    end
  end

  describe 'default_scope（Current.tenant）' do
    let(:other_user) { create(:user, tenant: other_tenant) }
    let!(:own_post) { described_class.create!(build_post_attributes.merge(user: user)) }
    let!(:foreign_post) { described_class.create!(build_post_attributes.merge(user: other_user)) }

    after { Current.reset }

    it 'Current.tenant をセットすると他テナントの Post が見えない' do
      Current.tenant = tenant

      expect(described_class.all).to contain_exactly(own_post)
      expect(described_class.find_by(id: foreign_post.id)).to be_nil
    end

    it 'Current.tenant が nil なら全件見える' do
      Current.tenant = nil

      expect(described_class.all).to contain_exactly(own_post, foreign_post)
    end

    it 'in_current_tenant スコープが定義されている' do
      Current.tenant = other_tenant

      expect(described_class.in_current_tenant).to contain_exactly(foreign_post)
    end
  end
end
