require 'rails_helper'

RSpec.describe VideoComment do
  let(:tenant) { create(:tenant) }
  let(:other_tenant) { create(:tenant) }
  let(:user) { create(:user, tenant: tenant) }
  let(:admin) { create(:admin, tenant: tenant) }
  let(:video_post) { create(:post, tenant: tenant, user: nil, admin: admin) }

  after(:each) { Current.reset }

  def build_comment(**attributes)
    described_class.new({ post: video_post, user: user, content: '本文' }.merge(attributes))
  end

  describe 'content' do
    it '空は invalid' do
      expect(build_comment(content: '')).not_to be_valid
    end

    it '1000 字は valid' do
      expect(build_comment(content: 'a' * 1000)).to be_valid
    end

    it '1001 字は invalid' do
      expect(build_comment(content: 'a' * 1001)).not_to be_valid
    end
  end

  describe '投稿者' do
    it 'user だけなら valid' do
      expect(build_comment(user: user, admin: nil)).to be_valid
    end

    it 'admin だけなら valid' do
      expect(build_comment(user: nil, admin: admin)).to be_valid
    end

    it '両方 nil は invalid' do
      expect(build_comment(user: nil, admin: nil)).not_to be_valid
    end

    it '両方ありは invalid' do
      expect(build_comment(user: user, admin: admin)).not_to be_valid
    end

    it '他テナントの user は invalid' do
      foreign_user = create(:user, tenant: other_tenant)

      expect(build_comment(user: foreign_user)).not_to be_valid
    end

    it '他テナントの admin は invalid' do
      foreign_admin = create(:admin, tenant: other_tenant)

      expect(build_comment(user: nil, admin: foreign_admin)).not_to be_valid
    end
  end

  describe 'tenant' do
    it '未指定なら post のテナントが入る' do
      comment = build_comment
      comment.valid?

      expect(comment.tenant).to eq(tenant)
    end

    it 'post と違う tenant を明示すると invalid' do
      expect(build_comment(tenant: other_tenant)).not_to be_valid
    end
  end

  describe 'parent' do
    let!(:top) { create(:video_comment, owner_tenant: tenant, post: video_post, user: user) }

    it '同じ post のトップレベルコメントを親にできる' do
      reply = build_comment(parent: top)

      expect(reply).to be_valid
    end

    it '別の post のコメントを親にすると invalid' do
      other_post = create(:post, tenant: tenant, user: nil, admin: admin)
      reply = build_comment(post: other_post, parent: top)

      expect(reply).not_to be_valid
    end

    it '返信を親にすると、保存時にトップレベルへ付け替わる' do
      first_reply = create(:video_comment, owner_tenant: tenant, post: video_post, user: user, parent: top)
      nested_reply = build_comment(parent: first_reply)

      nested_reply.save!

      expect(nested_reply.reload.parent_id).to eq(top.id)
    end

    it '付け替え後の親はトップレベル（parent_id nil）になる' do
      first_reply = create(:video_comment, owner_tenant: tenant, post: video_post, user: user, parent: top)
      nested_reply = create(:video_comment, owner_tenant: tenant, post: video_post, user: user, parent: first_reply)

      expect(nested_reply.reload.parent.parent_id).to be_nil
    end
  end

  describe 'scope top_level' do
    it 'parent_id が nil のものだけを返す' do
      top = create(:video_comment, owner_tenant: tenant, post: video_post, user: user)
      create(:video_comment, owner_tenant: tenant, post: video_post, user: user, parent: top)

      expect(described_class.top_level).to contain_exactly(top)
    end
  end

  describe 'replies' do
    it 'トップレベルを destroy すると返信も消える' do
      top = create(:video_comment, owner_tenant: tenant, post: video_post, user: user)
      create(:video_comment, owner_tenant: tenant, post: video_post, user: user, parent: top)

      expect { top.destroy }.to change { described_class.unscoped.count }.by(-2)
    end
  end

  describe '親レコードの destroy' do
    let!(:comment) { create(:video_comment, owner_tenant: tenant, post: video_post, user: user) }

    it 'post を destroy するとコメントも消える' do
      expect { video_post.destroy }.to change { described_class.unscoped.count }.by(-1)
    end

    it 'user を destroy するとコメントも消える' do
      expect { user.destroy }.to change { described_class.unscoped.count }.by(-1)
    end

    it 'admin を destroy するとコメントも消える' do
      admin_comment = create(:video_comment, :by_admin, owner_tenant: tenant, post: video_post, admin: admin)

      expect { admin.destroy }.to change { described_class.unscoped.where(id: admin_comment.id).count }.by(-1)
    end
  end

  describe 'default_scope（Current.tenant）' do
    let!(:own_comment) { create(:video_comment, owner_tenant: tenant) }
    let!(:foreign_comment) { create(:video_comment, owner_tenant: other_tenant) }

    it 'Current.tenant をセットすると他テナントのコメントが見えない' do
      Current.tenant = tenant

      expect(described_class.all).to contain_exactly(own_comment)
    end

    it 'Current.tenant が nil なら全件見える' do
      Current.tenant = nil

      expect(described_class.all).to contain_exactly(own_comment, foreign_comment)
    end
  end
end
