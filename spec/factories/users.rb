# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    trait :a do
      id { 1 }
      email { 'email@1.com' }
      name { 'name1' }
      password { 'password1' }
    end

    trait :b do
      id { 2 }
      email { 'email@2.com' }
      name { 'name2' }
      password { 'password2' }
    end

    trait :c do
      id { 3 }
      email { 'email@3.com' }
      name { 'name3' }
      password { 'password3' }
    end
  end
end
