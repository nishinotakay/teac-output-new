User.all.each do |u|
  50.times do |i|
    article = u.articles.new(
      title: "たいとる#{i} author #{u.name}",
      sub_title: "さぶたいとる#{i} author #{u.name}",
      content: "こんてんつ#{i} author #{u.name}"
    )
    article.save!
  end
end
