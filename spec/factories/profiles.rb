FactoryBot.define do
  factory :profile do
    birthday { '1990-08-01' }
    gender { 'male' }
    registration_date { '2023-08-09' }
    hobby { 'プログラミング' }
    association :user
  end
end
