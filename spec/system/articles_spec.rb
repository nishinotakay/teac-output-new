require 'rails_helper'

RSpec.describe 'Articles', type: :system do
  let(:user) { create(:user, :a, confirmed_at: Date.today) }

  describe 'redirect to #X' do
    let(:article) { create(:article, user: user) }
    before { sign_in(user) }

    context 'X = index' do
      it 'success' do
        article
        visit users_articles_path
        expect(current_path).to eq users_articles_path
        page.save_screenshot 'index.png'
        expect(page).to have_content '記事一覧'
        expect(page).to have_content 'タイトル〜サブタイトル〜'
        expect(page).to have_content '投稿者'
        expect(page).to have_content '投稿日'
        expect(page).to have_content article.title
        expect(page).to have_content article.sub_title
        expect(page).to have_content article.user.name
      end
    end

    context 'X = dashboards' do
      it 'success' do
        click_link 'DashBoard'
        click_link '記事作成'
        # click_link '記事投稿' リネームしたプルリクのマージ待ち
        # expect(page).to have_content('記事投稿', count: 2)
        expect(page).to have_content('記事投稿', count: 1)
      end
    end

    context 'X = show' do
      it 'success' do
      end
    end

    context 'X = new' do
      it 'success' do
      end
    end

    context 'X = edit' do
      it 'success' do
      end
    end
  end

  it 'create article' do
    click_link '記事作成'
    # click_link '記事投稿' リネームしたプルリクのマージ待ち
    fill_in "article[title]", with: 'title'
    fill_in "article[sub_title]", with: 'sub_title'
    fill_in "article[content]", with: 'content'
    expect(page).to have_content('title', count: 2)
    expect(page).to have_content('〜sub_title〜')
    expect(page).to have_content('content', count: 2)
    click_button '投稿'
    expect(page).to have_content('記事詳細')
    expect(page).to have_content('編集')
    expect(page).to have_content('削除')
    expect(page).to have_content('title')
    expect(page).to have_content('sub_title')
    expect(page).to have_content('content')
    page.save_screenshot '記事投稿.png'
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
