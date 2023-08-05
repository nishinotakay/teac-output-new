# frozen_string_literal: true

FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "タイトル_#{n}" }
    sequence(:sub_title) { |n| "サブタイトル_#{n}" }
    sequence(:content) { |n| "本文_#{n}" }
  end
end
