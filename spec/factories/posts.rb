FactoryBot.define do
  # postに「title」という別名を命名
  factory :post do
    # userモデルアソシエーション
    association :user
    # 40文字のランダム文字列
    # (バリテーションエラーのテストの為、モデルより1文字多く記載）
    title { Faker::Lorem.characters(number:31) }
    # 250文字のランダム文字列
    # (バリテーションエラーのテストの為、モデルより1文字多く記載）
    body { Faker::Lorem.characters(number:241) }
    # 400文字のランダム文字列
    youtube_url { Faker::Lorem.characters(number:400) }
  end
end