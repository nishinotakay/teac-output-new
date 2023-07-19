# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    name { '管理者' }
    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
