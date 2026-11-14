require 'rails_helper'

RSpec.describe Category, type: :model do
  it 'カテゴリーをDBに保存して読み直せる' do
    course = Course.create!(name: 'テストコース')

    category = Category.create!(
      name: '基本文法',
      course: course
    )

    saved_category = Category.find(category.id)

    expect(saved_category.name).to eq('基本文法')
    expect(saved_category.course_id).to eq(course.id)
  end
end
