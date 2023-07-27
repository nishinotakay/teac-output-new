# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "rspecテスト、タイトル_#{n}" }
    sequence(:sub_title) { |n| "rspecテスト、サブタイトル_#{n}" }
    sequence(:content) { |n| "rspecテスト、本文_#{n} app/assets/images/user_default.png" }
  end
end
