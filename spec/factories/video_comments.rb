FactoryBot.define do
  factory :video_comment do
    transient do
      owner_tenant { association(:tenant) }
    end

    tenant { owner_tenant }
    post { association :post, tenant: owner_tenant, user: association(:user, tenant: owner_tenant), admin: nil }
    user { association(:user, tenant: owner_tenant) }
    admin { nil }
    parent { nil }
    content { 'コメント本文' }

    trait :by_admin do
      user { nil }
      admin { association(:admin, tenant: owner_tenant) }
    end
  end
end
