class VideoComment < ApplicationRecord
  before_validation :set_tenant_from_post, on: :create
  before_validation :flatten_parent, on: :create

  belongs_to :tenant
  belongs_to :post
  belongs_to :user, optional: true
  belongs_to :admin, optional: true
  belongs_to :parent, class_name: 'VideoComment', optional: true
  has_many :replies, class_name: 'VideoComment', foreign_key: :parent_id, inverse_of: :parent, dependent: :destroy

  scope :in_current_tenant, -> { Current.tenant ? where(tenant: Current.tenant) : all }
  default_scope { in_current_tenant }
  scope :top_level, -> { where(parent_id: nil) }

  validates :content, presence: true, length: { maximum: 1000 }
  validate :exactly_one_author
  validate :tenant_matches_post
  validate :author_tenant_matches_post
  validate :parent_belongs_to_same_post

  private

  def set_tenant_from_post
    self.tenant ||= post&.tenant
  end

  # 返信への返信は 1 段目の親に付け替える
  def flatten_parent
    self.parent = parent.parent if parent&.parent_id
  end

  def exactly_one_author
    return if user_id.present? ^ admin_id.present?

    errors.add(:base, '投稿者は受講生か管理者のどちらか一方を指定してください')
  end

  def tenant_matches_post
    return if post.nil? || tenant_id == post.tenant_id

    errors.add(:tenant, 'が動画と一致しません')
  end

  def author_tenant_matches_post
    return if post.nil?

    author_tenant_id = (user || admin)&.tenant_id
    return if author_tenant_id.nil? || author_tenant_id == post.tenant_id

    errors.add(:base, '投稿者のテナントが動画と一致しません')
  end

  def parent_belongs_to_same_post
    return if parent.nil? || parent.post_id == post_id

    errors.add(:parent, 'が同じ動画のコメントではありません')
  end
end
