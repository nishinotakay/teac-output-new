# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "railsエンジニアのブログ記事_#{n}" }
    sequence(:sub_title) { |n| "railsエンジニアのためのブログ記事を書きました！_#{n}" }
    sequence(:content) { |n| "MyText_#{n}" }
  end
end
