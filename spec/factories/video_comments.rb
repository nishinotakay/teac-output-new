FactoryBot.define do
  factory :video_comment do
    transient do
      owner_tenant { create(:tenant) }
    end

    tenant { owner_tenant }
    post { association :post, tenant: owner_tenant, user: create(:user, tenant: owner_tenant), admin: nil }
    user { create(:user, tenant: owner_tenant) }
    admin { nil }
    parent { nil }
    content { 'コメント本文' }

    trait :by_admin do
      user { nil }
      admin { create(:admin, tenant: owner_tenant) }
    end
  end
end
