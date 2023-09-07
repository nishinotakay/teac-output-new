# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

50.times do |i|
  user = User.new(
    email:    "test_user#{i}@gmail.com", # sample: test_user1@gmail.com
    name:     "テストuser#{i}",
    password: 'password'
  )

  user.skip_confirmation! # deviseの確認メールをスキップ
  user.save!
end

names = %i[生澤智史 菅原靖人 養性光明 元永真広 西野鷹也 江草誠]
emails = %i[ikezawa@test.com sugawara@test.com yosei@test.com motonaga@test.com nishino@test.com egusa@test.com]

6.times do |i|
  user = User.new(
    name:     names[i],
    email:    emails[i],
    password: 'password'
  )

  user.skip_confirmation! # deviseの確認メールをスキップ
  user.save!
end

User.all.each do |u|
  50.times do |i|
    article = u.articles.new(
      title:     "たいとる#{i} author #{u.name}",
      sub_title: "さぶたいとる#{i} author #{u.name}",
      content:   "こんてんつ#{i} author #{u.name}"
    )
    article.save!
  end
end

manager = Manager.new(
  email:    'test_manager@gmail.com',
  name:     'テストmanager1',
  password: 'password'
)

manager.skip_confirmation! # deviseの確認メールをスキップ
manager.save!

admin = Admin.new(
  email:    'test_admin@gmail.com',
  name:     'テストadmin1',
  password: 'password'
)

admin.skip_confirmation! # deviseの確認メールをスキップ
admin.save!

300.times do
  user = User.order('RAND()').first

  post = Post.new(
    title:       'たいとる',
    body:        'ないよう',
    youtube_url: 'https://www.youtube.com/watch?v=MQG-xF7bv1I&t=4s', # seedで作った動画見られない。手動は見られる。
    user:        user
  )

  post.save!
end

50.times do |n| # テナント作成
  Tenant.create!(name: "テナント#{n+1}")
end

puts "Tenants Created"

Profile.create!(birthday: '1990-03-30',
  gender: 'male',
  registration_date: '2018-01-01',
  hobby: '野球',
  user_id: '1')
Profile.create!(birthday: '1992-04-10',
  gender: 'female',
  registration_date: '2019-02-02',
  hobby: '読書',
  user_id: '2')
Profile.create!(birthday: '1997-08-18',
  gender: 'female',
  registration_date: '2019-06-06',
  hobby: 'サーフィン',
  user_id: '3')
Profile.create!(birthday: '1960-09-30',
  gender: 'male',
  registration_date: '2019-09-06',
  hobby: '将棋',
  user_id: '4')
Profile.create!(birthday: '2000-12-25',
  gender: 'male',
  registration_date: '2022-05-05',
  hobby: '食べ歩き',
  user_id: '5')

  puts "Profile Created"

User.all.each do |u|
  5.times do |i|
    tweet = u.tweets.create!(post: "つぶやきコンテント#{i + 1}")
  end
end