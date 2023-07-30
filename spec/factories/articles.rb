# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "rspecテスト、タイトル_#{n}" }
    sequence(:sub_title) { |n| "rspecテスト、サブタイトル_#{n}" }
    sequence(:content) { |n| "rspecテスト、本文_#{n}" }
    # sequence(:content) { |n| "rspecテスト、本文_#{n} <img alt=\"画像\" src=\"#{Rails.root.join('spec/fixtures/files/ruby.png')}\">\r\n" }
  end
end
