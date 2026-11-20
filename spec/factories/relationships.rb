# frozen_string_literal: true

FactoryBot.define do
  factory :relationship do
    follower factory: :user
    followed { association :user, tenant: follower.tenant }
  end
end
