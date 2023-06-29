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
