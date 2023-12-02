require 'rails_helper'

RSpec.describe 'Posts', type: :system do
  let!(:user) { create(:user) }

  before(:each) do
    user.confirm
    sign_in(user)
  end

  describe '動画投稿新規登録' do
    context '入力内容が正しい場合' do
      it '投稿に成功する' do
        visit new_users_post_path
        fill_in 'post_title', with: 'Rspec'
        fill_in 'post_text', with: 'Rspecに関する動画です。'
        fill_in 'post_youtube_url', with: 'https://www.youtube.com/watch?v=AgeJhUvEezo'
        click_button '登録する'
        expect(page).to have_content '動画を投稿しました'
        expect(page).to have_current_path users_post_path(user), ignore_query: true
        expect(page).to have_content 'Rspec'
        expect(page).to have_content 'Rspecに関する動画です。'
      end
    end

    context '入力内容が正しくない場合' do
      it '投稿に失敗する' do
        visit new_users_post_path
        fill_in 'post_title', with: ''
        fill_in 'post_text', with: ''
        fill_in 'post_youtube_url', with: ''
        click_button '登録する'
        expect(page).to have_content 'タイトルを入力してください'
        expect(page).to have_current_path users_posts_path, ignore_query: true
      end
    end
  end

  describe '動画投稿編集' do
    let!(:post) { create(:post, title: 'Ruby', body: 'Ruby初心者向け', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', user: user) }

    context '編集内容が正しい場合' do
      it '更新に成功する' do
        visit users_posts_path
        click_button '︙'
        find('.dropdown-menu li:contains("編集") a.nav-link').click
        fill_in 'post_title', with: 'Rails'
        fill_in 'post_text', with: 'Rails初心者向け'
        fill_in 'post_youtube_url', with: 'https://www.youtube.com/watch?v=AgeJhUvEezo'
        click_button '更新する'
        expect(page).to have_content '動画情報を更新しました'
        expect(page).to have_current_path users_post_path(post), ignore_query: true
        expect(page).to have_content 'Rails'
        expect(page).to have_content 'Rails初心者向け'
      end
    end

    context '編集内容が正しくない場合' do
      it '更新に失敗する' do
        visit users_posts_path
        click_button '︙'
        find('.dropdown-menu li:contains("編集") a.nav-link').click
        fill_in 'post_title', with: 'Rails'
        fill_in 'post_text', with: ''
        fill_in 'post_youtube_url', with: 'https://www.youtube.com/watch?v=AgeJhUvEezo'
        click_button '更新する'
        expect(page).to have_content '内容を入力してください'
        expect(page).to have_current_path users_post_path(post), ignore_query: true
        expect(page).to have_field('post_title', with: 'Rails')
        expect(page).to have_field('post_text', placeholder: '内容 (必須 240文字まで)')
        expect(page).to have_field('post_youtube_url', with: 'https://www.youtube.com/watch?v=AgeJhUvEezo')
      end
    end

    context '自分以外の投稿の場合' do
      let!(:user_a) { create(:user, name: 'タモリ') }
      let!(:other_post) { create(:post, title: 'SQL', body: 'SQL説明動画パート１', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', user: user_a) }

      it '編集できないこと' do
        visit users_posts_path
        # 一番上の「︙」ボタンをクリック
        find('tbody tr:first-child td button.btn').click
        # 一番上ドロップダウンメニュー内で「閲覧」のみが表示されていることを確認
        expect(page).to have_selector('tbody tr:first-child td ul.dropdown-menu li a.nav-link', text: '閲覧')
        expect(page).not_to have_selector('tbody tr:first-child td ul.dropdown-menu li .nav-link', text: '編集')
        expect(page).not_to have_selector('tbody tr:first-child td ul.dropdown-menu li .nav-link', text: '削除')
      end
    end
  end

  describe '動画投稿一覧' do
    let(:user_1) { create(:user, name: '鈴木一郎') }
    let(:user_2) { create(:user, name: '大谷翔平') }
    let!(:my_post) { create(:post, title: 'Ruby', body: 'Rubyについての動画です', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', created_at: DateTime.new(2023, 11, 10), user: user_1) }
    let!(:post_1) { create(:post, title: 'SQL', body: 'SQLについての動画です', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', created_at: DateTime.new(2023, 11, 11), user: user_2) }
    let!(:post_2) { create(:post, title: 'JS', body: 'Javascriptについての動画です', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', created_at: DateTime.new(2023, 11, 12), user: user_1) }

    it '全ての動画投稿が表示されること' do
      visit users_posts_path
      expect(page).to have_content 'Ruby'
      expect(page).to have_content 'SQLについての動画です'
      expect(page).to have_selector('iframe[src*="youtube.com/embed"]')
    end

    context '並べ替えをする場合' do
      it '投稿日の古い順に並び替えができること' do
        visit users_posts_path
        find('.btn-success.sort-modal-btn', visible: :all).click # 並べ替えボタンが非表示要素になっているため'click_on'並べ替え'が使えない
        select '古い順', from: 'sort-select'
        find('.btn-primary.submit-btn', visible: :all, match: :first).click
        expect(page).to have_selector('.post-title:first-child', text: 'Ruby')
      end

      it '投稿日の新しい順に並び替えができること' do
        visit users_posts_path
        find('.btn-success.sort-modal-btn', visible: :all).click # 並べ替えボタンが非表示要素になっているため'click_on'並べ替え'が使えない
        select '新しい順', from: 'sort-select'
        find('.btn-primary.submit-btn', visible: :all, match: :first).click
        expect(page).to have_selector('.post-title:first-child', text: 'JS')
      end
    end

    context '絞り込み検索をする場合' do
      it '投稿者名で絞り込みができること' do
        visit users_posts_path
        find('.btn-success.filter-modal-btn', visible: :all).click
        fill_in 'input-author', with: '鈴木一郎'
        find('.btn-primary.submit-btn', visible: :all, match: :first).click
        expect(page).to have_content('Ruby')
        expect(page).to have_content('JS')
      end

      it 'タイトルで絞り込みができること' do
        visit users_posts_path
        find('.btn-success.filter-modal-btn', visible: :all).click
        fill_in 'input-title', with: 'SQL'
        find('.btn-primary.submit-btn', visible: :all, match: :first).click
        expect(page).to have_content('SQL')
        expect(page).to have_content('SQLについての動画です')
      end

      it '投稿日で絞り込みができること' do
        visit users_posts_path
        find('.btn-success.filter-modal-btn', visible: :all).click
        fill_in 'input-start', with: '2023, 11, 10'
        fill_in 'input-finish', with: '2023, 11, 11'
        find('.btn-primary.submit-btn', visible: :all, match: :first).click
        expect(page).to have_content('Ruby')
        expect(page).to have_content('SQL')
      end
    end
  end

  describe '動画投稿削除' do
    let(:user) { create(:user) }
    let(:admin) { create(:admin) }
    let!(:my_post) { create(:post, title: 'Ruby', body: 'Rubyについての動画です', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', created_at: DateTime.new(2023, 11, 10), user: user) }
    let!(:admin_post) { create(:post, title: 'SQL', body: 'SQLについての動画です', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', created_at: DateTime.new(2023, 11, 11), admin: admin) }

    it '自分の投稿を削除できること' do
      visit users_posts_path
      find('tbody tr:nth-child(2) td button.btn-menu').click
      find('.dropdown-menu li:contains("削除") a.nav-link').click
      expect(page).not_to have_content('Ruby')
    end

    it '他人の投稿を削除できないこと ' do
      visit users_posts_path
      find('tbody tr:first-child td button.btn-menu').click
      expect(page).not_to have_selector('tbody tr:first-child td ul.dropdown-menu li .nav-link', text: '削除')
    end
  end
end
