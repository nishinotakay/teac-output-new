names = %i(生澤智史 菅原靖人 養性光明 元永真広 西野鷹也 江草誠)
emails = %i(ikezawa@test.com sugawara@test.com yosei@test.com motonaga@test.com nishino@test.com egusa@test.com)

6.times do |i|
  user = User.new(
    name: names[i],
    email: emails[i],
    password: "password"
  )

  user.skip_confirmation! # deviseの確認メールをスキップ
  user.save!
end
