require 'rails_helper'

RSpec.describe 'Articles', type: :system do
  let(:user_a) { create(:user, :a, confirmed_at: Date.today) }
  let(:user_b) { create(:user, :b, confirmed_at: Date.today) }
  let(:article) { create(:article, user: user_a) }

  describe 'redirect to #X' do
    before { sign_in(user_a); article }

    context 'X = index' do
      it 'success' do
        visit users_articles_path
        expect(current_path).to eq users_articles_path
        expect(page).to have_content '記事一覧'
        expect(page).to have_content 'タイトル〜サブタイトル〜'
        expect(page).to have_content '投稿者'
        expect(page).to have_content '投稿日'
        expect(page).to have_content article.title
        expect(page).to have_content article.sub_title
        expect(page).to have_content article.user.name
        expect(page).to have_content article.created_at.strftime('%-m/%d %-H:%M')
      end
    end

    context 'X = dashboards' do
      it 'success' do
        visit users_dash_boards_path
        expect(current_path).to eq users_dash_boards_path
        expect(page).to have_content '投稿した記事一覧'
        expect(page).to have_content 'タイトル〜サブタイトル〜'
        expect(page).to have_content '投稿日'
        expect(page).to_not have_content '投稿者'
        expect(page).to have_content article.title
        expect(page).to have_content article.sub_title
        expect(page).to have_content article.created_at
        expect(page).to have_content article.created_at.strftime('%-m/%d %-H:%M')
      end
    end

    context 'X = show' do
      context 'writer' do
        it 'success' do
          visit users_article_path(article)
          expect(current_path).to eq users_article_path(article)
          expect(page).to have_content '編集'
          expect(page).to have_content '削除'
          expect(page).to have_content article.title
          expect(page).to have_content article.sub_title
          expect(page).to have_content article.content
          expect(page).to_not have_content article.user.name, count: 2
        end
      end

      context 'non_writer' do
        it 'success' do
          click_link 'ログアウト'
          sign_in(user_b)
          visit users_article_path(article)
          expect(current_path).to eq users_article_path(article)
          expect(page).to_not have_content '編集'
          expect(page).to_not have_content '削除'
          expect(page).to have_content '書き手'
          expect(page).to have_content article.user.name
          expect(page).to have_content article.title
          expect(page).to have_content article.sub_title
          expect(page).to have_content article.content
        end
      end
    end


    context 'X = new' do
      it 'success' do
        visit new_users_article_path
        expect(current_path).to eq new_users_article_path
        expect(page).to have_content "記事投稿"
        expect(page).to have_content "新規記事"
        expect(page).to have_content "タイトル", count: 2
        expect(page).to have_content "プレビュー"
        expect(page).to have_content "投稿"
        page.save_screenshot 'new.png'
      end
    end

    context 'X = edit' do
      it 'success' do
        visit edit_users_article_path(article)
        expect(current_path).to eq edit_users_article_path(article)
        expect(page).to have_content "記事編集"
        expect(page).to have_content "新規記事"
        expect(page).to have_content "タイトル", count: 2
        expect(page).to have_content "プレビュー"
        expect(page).to have_content "投稿"
        page.save_screenshot 'new.png'
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
