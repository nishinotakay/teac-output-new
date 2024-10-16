# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "admin#{n}@example.com" }
    name { '管理者' }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
