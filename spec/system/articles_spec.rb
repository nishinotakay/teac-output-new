require 'rails_helper'

RSpec.describe 'Articles', type: :system do
  let(:user) { create(:user, :a, confirmed_at: Date.today) }

  before { sign_in(user) }

  context '#index to #new' do
    click_link '記事一覧'
    page.save_screenshot
    click_link '記事投稿'
    page.save_screenshot
  end

  it 'create article' do
    click_link '記事投稿'
    fill_in "article[title]", with: 'title'
    fill_in "article[sub_title]", with: 'sub_title'
    fill_in "article[content]", with: 'content'
    page.save_screenshot
  end
end



RSpec.describe 'Profiles', type: :system do
  it 'user creates a new profile' do
    user = FactoryBot.create(:user, :a)

    # ログイン操作
    visit root_path
    fill_in 'user[email]', with: user.email
    fill_in 'user[password]', with: user.password
    click_button 'ログイン'

    # プロフィール作成
    subject do
      click_link 'プロフィール作成'
      fill_in 'name', with: user.name
      fill_in 'purpose', with: user.purpose
      click_button '登録する'
    end
    # before do
    #   driven_by(:rack_test)
    # end

    # pending "add some scenarios (or delete) #{__FILE__}"
  end
end
