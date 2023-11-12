require 'rails_helper'

RSpec.describe 'Posts', type: :system do
  let(:user) { create(:user) }
  before do
    user.confirm
    sign_in(user)
  end

  describe '動画投稿新規登録のテスト' do
    context '入力内容が正しい場合' do
      it '投稿に成功する' do
        visit new_users_post_path
        fill_in 'post_title', with: 'Rspec'
        fill_in 'post_text', with: 'Rspecに関する動画です。'
        fill_in 'post_youtube_url', with: 'https://www.youtube.com/watch?v=AgeJhUvEezo'
        click_button '登録する'
        expect(page).to have_content '動画を投稿しました'
        expect(current_path).to eq users_post_path(user)
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
        expect(current_path).to eq users_posts_path
      end
    end
  end
  
  describe '動画投稿編集のテスト' do
    let!(:post) { create(:post, title: 'Ruby', body: 'Ruby初心者向け', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', user: user)}
    
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
          expect(current_path).to eq users_post_path(post)
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
        expect(current_path).to eq users_post_path(post)
        expect(page).to have_field('post_title', with: 'Rails')
        expect(page).to have_field('post_text', placeholder: '内容 (必須 240文字まで)')
        expect(page).to have_field('post_youtube_url', with: 'https://www.youtube.com/watch?v=AgeJhUvEezo')
      end
    end

    context '自分以外の投稿の場合' do
      let!(:user_a) { create(:user, name: 'タモリ') }
      let!(:other_post) {  create(:post, title: 'SQL', body: 'SQL説明動画パート１', youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo', user: user_a)}
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
    let!(:my_post) { create(:post), title: 'Ruby', user: user }
    let!(:admin_post) { create(:post), body: 'SQLについての動画です', admin: admin }
    let!(:other_post) { create(:post), youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo' }

    it '全ての動画投稿が表示されること' do
      動画投稿一覧ページにアクセス     
      expect(page).to have_content 'Ruby'
      expect(page).to have_content 'SQLについての動画です'
      expect(page).to have_content 'https://www.youtube.com/watch?v=AgeJhUvEezo'
    end

    context '並び替えをする場合' do
      動画投稿一覧ページにアクセス
      並び替えボタンを押す
      it '投稿日の古い順に並び替えができること' do
        プルダウンで古い順を選択
        並び替えるボタンを押す
        一番古い投稿が一番上に表示
      end
      it '投稿日の新しい順に並び替えができること' do
        プルダウンで新しい順を選択
        並び替えるボタンを押す
        一番新しい投稿が一番上に表示
      end
    end

    context '絞り込み検索をする場合' do
      動画投稿一覧ページにアクセス
      絞り込み検索ボタンを押す
      it '投稿者名で絞り込みができること' do
        投稿者フォームに名前を入力する
        検索するボタンを押す
        正しい投稿が表示されている
      end
      it 'タイトルで絞り込みができること' do
        タイトルフォームに入力する
        検索ボタンを押す
        正しい投稿が表示されている
      end
      it '投稿日で絞り込みができること' do
        開始日、終了日に日付を入力する
        検索ボタンを押す
        正しい投稿が表示されている
      end
    end
  end

  # describe '動画投稿削除のテスト' do
  #   let!(:my_post) { create(:post), title: 'Ruby', user: user }
  #   let!(:admin_post) { create(:post), body: 'SQLについての動画です', admin: admin }
  #   let!(:other_post) { create(:post), youtube_url: 'https://www.youtube.com/watch?v=AgeJhUvEezo' }

  #   動画投稿一覧ページにアクセス
  #   it '自分の投稿を削除できること' do
  #     自分の投稿の三点リーダをクリック
  #     削除ボタンを押す
  #     OKボタンを押す
  #     一覧ページに削除した投稿が表示されていない
  #   end

  #   it '他人の投稿を削除できないこと ' do
  #     他人の三点リーダをクリック
  #     削除ボタンが表示されていない
  #   end

  # end
  
end