FactoryBot.define do
  factory :profile do
    # association :user
    purpose { 'railsエンジニアになるため' }
    user
  end
end
