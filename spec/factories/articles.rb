# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    sequence(:title, 'railsエンジニアのブログ記事_1')
    sequence(:sub_title, 'railsエンジニアのためのブログ記事を書きました！_1')
    sequence(:content, 'MyText_1')
  end
end
