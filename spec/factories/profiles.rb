FactoryBot.define do
  factory :profile do
    # association :user    
    name { '田中 浩' }
    purpose { 'railsエンジニアになるため' }
    user
  end
end
