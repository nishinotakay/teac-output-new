require 'rails_helper'

RSpec.describe 'Articles', type: :system do
  let(:user) { create(:user, confirmed_at: Date.today) }
  let(:user_1) { create(:user, :a, confirmed_at: Date.today) }
  let(:user_2) { create(:user, :b, confirmed_at: Date.today) }
  let(:article) { Article.create(title: 'RSpec', sub_title: 'system', content: 'test', user: user) }
  let(:article_1) { Article.create(title: 'RSpec', sub_title: 'system', content: 'test', user: user_1) }
  let(:article_2) { create(:article, user: user_2) }
  let(:article_30) { create_list(:article, 30, user: user) }
  let(:article_148) { create_list(:article, 148, user: user) }

  before(:each) do
    sign_in(user)
    article
  end

  describe '記事一覧画面' do # index
    before(:each) do
      article_2.update(created_at: Time.current + 1.minute)
      visit users_articles_path(order: 'DESC')
    end

    it '現在のパスが記事一覧画面のパスである' do
      expect(page).to have_current_path users_articles_path, ignore_query: true
    end

    describe '表示テスト' do
      it '画面の見出しに記事一覧が表示される' do
        expect(page).to have_selector('h1', text: '記事一覧')
      end

      it '正しいテーブルヘッダーが表示されていること' do
        expect(page).to have_selector('th', text: 'タイトル')
        expect(page).to have_selector('th', text: 'サブタイトル')
        expect(page).to have_selector('th', text: '投稿者')
        expect(page).to have_selector('th', text: '投稿日時')
      end

      it '全ての記事が一覧表示される' do
        # 確認すべき内容を配列でまとめて、eachで回す
        [article, article_2].each do |article|
          expect(page).to have_content article.title
          expect(page).to have_content article.sub_title
          expect(page).to have_content article.user.name
          expect(page).to have_content article.created_at.strftime('%Y/%m/%d %H:%M')
        end
      end

      context '３点リーダー' do
        it '全ての記事に３点リーダーが表示されている' do
          expect(page.all('button', text: '︙').count).to eq 2 # テスト記事は2件
        end

        context 'ログインユーザーの投稿記事' do
          context '３点リーダー押下' do
            before(:each) do
              page.all(:button, '︙')[1].click # 一覧の1つ目[1]がログインユーザー（user）の記事
              # find_button( '︙', match: :first).click
              # click_button '︙', match: :first もOK
              # find('button', text: '︙', match: :first).click もOK
            end

            it '閲覧・編集・削除ボタンが表示される' do
              expect(page).to have_content('閲覧')
              expect(page).to have_content('編集')
              expect(page).to have_content('削除')
            end
          end
        end

        context 'ログインユーザー以外の記事' do
          before '３点リーダー押下' do
            page.all(:button, '︙')[0].click
          end

          it '閲覧ボタンのみ表示される' do
            expect(page).to have_content('閲覧')
            expect(page).not_to have_content('編集')
            expect(page).not_to have_content('削除')
          end
        end
      end

      context 'ページネーション' do
        before(:each) do
          article_30
          visit current_path
        end

        it 'ページ割で表示される' do
          page.execute_script('window.scroll(0, 1000)') # ページ割部分まで下へスクロール
          expect(page).to have_selector '.pagination' # 不要なテストかも
          expect(page).to have_selector('.article-paginate') # 不要なテストかも
          expect(page).to have_link('1', class: 'page-link')
          expect(page).to have_link('2', class: 'page-link')
          expect(page).to have_link('›', class: 'page-link')
          expect(page).to have_link('»', class: 'page-link')
          # expect(page).to have_link('...', class: 'page-link') 5ページ以上から...が表示される
        end
      end

      context '並べ替えボタン' do
        it '表示されている' do
          expect(page).to have_button('並べ替え')
        end

        context '並べ替えボタン押下' do
          it 'モーダルが表示される' do
            find_button(text: '並べ替え').click
            expect(page).to have_css('.modal.fade.show')
            expect(page).to have_css('.modal-title', text: '並べ替え')
            expect(page).to have_content '投稿日時'
            expect(page).to have_select('sort-select')
            find_field('sort-select').click
            expect(page).to have_select('sort-select', selected: '新しい順')
            expect(page).to have_select('sort-select', text: '古い順')
            expect(page).to have_button '並べ替える'
            expect(page).to have_button '戻る'
          end
        end
      end

      context '絞り込み検索ボタン' do
        it '表示されている' do
          expect(page).to have_button('絞り込み検索')
          find_button(text: '絞り込み検索').click
        end

        context '絞り込み検索ボタン押下' do
          it 'モーダルが表示される' do
            find_button(text: '絞り込み検索').click
            expect(page).to have_css('.modal.fade.show')
            expect(page).to have_css('.modal-title', text: '絞り込み検索')
            expect(page).to have_content '投稿者'
            expect(page).to have_selector('input#input-author')
            expect(page).to have_content 'タイトル'
            expect(page).to have_selector('input#input-title')
            expect(page).to have_content 'サブタイトル'
            expect(page).to have_selector('input#input-subtitle')
            expect(page).to have_content '本文'
            expect(page).to have_selector('input#input-content')
            expect(page).to have_content '投稿日時'
            expect(page).to have_selector('input#input-start[type="date"]')
            expect(page).to have_selector('input#input-finish[type="date"]')
            expect(page).to have_button '検索する'
            expect(page).to have_button '戻る'
          end
        end
      end
    end

    describe '遷移テスト' do
      context 'ログインユーザーの投稿記事' do
        context 'タイトルを押下' do
          before(:each) do
            find('#article-title', text: article.title).click
          end

          it '記事詳細画面へ遷移する' do
            expect(page).to have_current_path users_article_path(article), ignore_query: true
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.content
          end

          it '編集・削除ボタンが表示される' do
            expect(page).to have_content('編集')
            expect(page).to have_content('削除')
          end
        end

        context 'サブタイトルを押下' do
          before(:each) do
            find('#article-subtitle', text: article.sub_title).click
          end

          it '記事詳細画面へ遷移する' do
            expect(page).to have_current_path users_article_path(article), ignore_query: true
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.content
          end

          it '編集・削除ボタンが表示される' do
            expect(page).to have_content('編集')
            expect(page).to have_content('削除')
          end
        end

        context '投稿日時を押下' do
          before(:each) do
            find('#article-createdat', text: article.created_at.strftime('%Y/%m/%d %H:%M')).click
          end

          it '記事詳細画面へ遷移する' do
            expect(page).to have_current_path users_article_path(article), ignore_query: true
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.content
          end

          it '編集・削除ボタンが表示される' do
            expect(page).to have_content('編集')
            expect(page).to have_content('削除')
          end
        end
      end

      context 'ログインユーザー以外の記事' do
        context 'タイトルを押下' do
          before(:each) do
            find('#article-title', text: article_2.title).click
          end

          it '記事詳細画面へ遷移する' do
            expect(page).to have_current_path users_article_path(article_2), ignore_query: true
            expect(page).to have_content article_2.title
            expect(page).to have_content article_2.sub_title
            expect(page).to have_content article_2.content
            expect(page).to have_content user_2.name
          end

          it '編集・削除ボタンが表示されない' do
            expect(page).not_to have_content('編集')
            expect(page).not_to have_content('削除')
          end
        end

        context 'サブタイトルを押下' do
          before(:each) do
            find('#article-subtitle', text: article_2.sub_title).click
          end

          it '記事詳細画面へ遷移する' do
            expect(page).to have_current_path users_article_path(article_2), ignore_query: true
            expect(page).to have_content article_2.title
            expect(page).to have_content article_2.sub_title
            expect(page).to have_content article_2.content
            expect(page).to have_content user_2.name
          end

          it '編集・削除ボタンが表示されない' do
            expect(page).not_to have_content('編集')
            expect(page).not_to have_content('削除')
          end
        end

        context '投稿日時を押下' do
          before(:each) do
            find('#article-createdat', text: article_2.created_at.strftime('%Y/%m/%d %H:%M')).click
          end

          it '記事詳細画面へ遷移する' do
            expect(page).to have_current_path users_article_path(article_2), ignore_query: true
            expect(page).to have_content article_2.title
            expect(page).to have_content article_2.sub_title
            expect(page).to have_content article_2.content
            expect(page).to have_content user_2.name
          end

          it '編集・削除ボタンが表示されない' do
            expect(page).not_to have_content('編集')
            expect(page).not_to have_content('削除')
          end
        end
      end

      context 'ログインユーザーの記事３点リーダー' do # この箇所で、高速テストの影響で、不安定なエラー発生する！解決案は, wait: 10 か、sleep 1
        before(:each) do
          page.all('.btn', text: '︙')[1].click # 2番目を押下
          # click_button '︙', match: :first 1番目を押下、この記述だと２番目以降を押下指定する実装不可
        end

        context '閲覧ボタン押下' do
          before(:each) do
            # click_link '閲覧'
            # find('a.nav-link', text: '閲覧').click
            find_link('閲覧').click
            # sleep 1 # ないと時々エラー
          end

          it '記事詳細画面へ遷移する' do
            expect(page).to have_current_path users_article_path(article), ignore_query: true
            expect(page).to have_content(article.title)
            expect(page).to have_content(article.sub_title)
            expect(page).to have_content(article.content, wait: 10)
          end

          it '編集・削除ボタンが表示される' do
            expect(page).to have_content('編集', wait: 10)
            expect(page).to have_content('削除')
          end
        end

        context '編集ボタン押下' do
          before(:each) do
            click_link '編集'
          end

          it '編集ボタン押下で記事編集画面へ遷移する' do
            expect(page).to have_current_path edit_users_article_path(article), ignore_query: true
            expect(page).to have_field('article_title', with: article.title)
            expect(page).to have_field('article_sub_title', with: article.sub_title)
            expect(page).to have_field('article_content', with: article.content)
          end
        end
      end

      context 'ログインユーザー以外の記事の３点リーダー、閲覧ボタン押下' do
        before(:each) do
          page.all(:button, '︙')[0].click
          # click_button '︙', match: :first #, visible: false
          click_link '閲覧'
          # find_link('閲覧', wait: 10).click
          # sleep 1 これよりも , have_content オプションで wait: 10 が良いらしい
        end

        it '記事詳細画面へ遷移する' do
          sleep 1
          expect(page).to have_current_path users_article_path(article_2), ignore_query: true
          expect(page).to have_content article_2.title
          expect(page).to have_content article_2.sub_title
          expect(page).to have_content article_2.content
          expect(page).to have_content user_2.name
        end

        it '編集・削除ボタンが表示されない' do
          expect(page).not_to have_content('編集')
          expect(page).not_to have_content('削除')
        end
      end

      describe 'ページネーション' do
        # let(article_148) { create_list(:article, 148, title: "paginate_#{i}", sub_title: "paginate_sub_#{i}", content: "paginate_content_#{i}") }

        before(:each) do
          article_148
          visit current_path
          page.execute_script('window.scroll(0, 1000)')
        end

        it '1を押下で、1ページ目へ遷移する' do
          find('.page-link', text: '2').click
          # sleep 1
          page.execute_script('window.scroll(0, 1000)')
          # wait_for_ajax_without_jquery
          find('.page-link', text: '1').click
          sleep 1
          page.execute_script('window.scroll(0, 1000)')
          background_color = find_link('1').native.css_value('background-color')
          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_content 'paginate_120'
        end

        it '3を押下で、3ページ目へ遷移する' do
          find('.page-link', text: '3').click
          sleep 1
          page.execute_script('window.scroll(0, 1000)')
          background_color = find('.page-link', text: '3').native.css_value('background-color')
          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_content 'paginate_60'
          # expect(page).to have_selector('a', text: '3', class: 'page-link')
        end

        it '5を押下で、5ページ目へ遷移する' do
          find('.page-link', text: '5').click
          sleep 1
          page.execute_script('window.scroll(0, 1000)')
          background_color = find_link('5').native.css_value('background-color')

          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_content 'paginate_0'
          # sleep 2
          # expect(page).to have_selector('a', text: '5', class: 'page-link')
        end

        it '›を押下で、次のページへ遷移する' do
          find('.page-link', text: '›').click
          sleep 1
          page.execute_script('window.scroll(0, 1000)')
          background_color = find_link('2').native.css_value('background-color')

          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_content 'paginate_90'
          # expect(page).to have_selector('a', text: '2', class: 'page-link')
        end

        it '»を押下で、最終ページへ遷移する' do
          find('.page-link', text: '»').click
          sleep 2
          page.execute_script('window.scroll(0, 1000)')
          background_color = find_link('5').native.css_value('background-color')

          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_selector('a', text: '5', class: 'page-link')
          # expect(page).to have_content 'paginate_0'
          expect(page).not_to have_selector('a', text: '»', class: 'page-link')
        end

        it '‹を押下で、前のページへ遷移する' do
          find('.page-link', text: '»').click
          # sleep 1
          page.execute_script('window.scroll(0, 1000)')
          # wait_for_ajax_without_jquery
          find('.page-link', text: '‹').click
          sleep 1
          page.execute_script('window.scroll(0, 1000)')
          background_color = find_link('4').native.css_value('background-color')
          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_content 'paginate_30'
          # expect(page).to have_selector('a', text: '4', class: 'page-link')
        end

        it '«を押下で、最初のページへ遷移する' do
          find('.page-link', text: '»').click
          sleep 1
          page.execute_script('window.scroll(0, 1000)')
          find('.page-link', text: '«').click
          page.execute_script('window.scroll(0, 1000)')
          sleep 1
          background_color = find_link('1').native.css_value('background-color')
          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_content 'paginate_120'
          expect(page).not_to have_selector('.page-link', text: '«', class: 'page-link')
        end
      end
    end

    describe '機能テスト' do
      it '３点リーダーから記事の削除ができる' do
        # ログインユーザーの記事の３点リーダーから削除ボタンを押下する

        article_first = Article.first.id
        page.all('.btn', text: '︙')[1].click # click_link '︙', match: :first は ×
        # click_link '削除'
        find_link('削除').click
        expect {
          expect(page.accept_confirm).to eq '選択した記事を削除します。' # accept_confirm はデフォルトで OK 押下する
          expect(page).to have_content('記事を削除しました。', wait: 10)
        }.to change(user.articles, :count).by(-1)
        expect(page).not_to have_content article.title
        expect(page).not_to have_content article.sub_title
        expect(page).not_to have_content article.user.name
        expect(Article.exists?(article_first)).to be_falsey # DBに無い
        # expect(Article.where(id: article_first).count).to eq 0 # DBに無い
        # page.accept_confirm('選択した記事を削除します。') do # accept_confirm のデフォルトがOK押下する！

        # click_button "OK"
        # confirm
        # sleep 1 ここだとエラー！処理速度が速いせいで！
        # end
        # 記事が削除されていることを確認する
        # sleep 1
      end

      context '並べ替えボタン' do
        before(:each) do
          article_2.update(created_at: Time.current)
          article_30
          visit current_path
        end

        context '新しい順を選択' do
          it '降順になる' do
            find_button(text: '並べ替え').click
            # find('.form-select').click
            find('.form-select', text: '新しい順').click
            find_button(text: '並べ替える').click
            # first_article_title = find('#article-title', match: :first).text
            expect(find('#article-title', match: :first).text).to eq Article.last.title
          end
        end

        context '古い順を選択' do
          it '昇順になる' do
            find_button(text: '並べ替え').click
            # find('.form-select').click
            find('.form-select option[value="ASC"]').click
            find_button(text: '並べ替える').click
            # sleep 3

            expect(find('#article-title', match: :first).text).to eq Article.first.title
          end
        end
      end

      context '絞り込み検索ボタン' do
        before(:each) do
          # article
          find_button(text: '絞り込み検索').click
        end

        context '投稿者名を入力' do
          context '条件を満たすデータが存在する場合' do
            it '完全一致する記事を返す' do
              fill_in 'input-author', with: '山田太郎'
              find_button(text: '検索する').click
              expect(page).to have_content article.title
              expect(page).to have_content article.sub_title
              expect(page).to have_content article.user.name
            end

            it '前方一致する記事を返す' do
              fill_in 'input-author', with: '山'
              find_button(text: '検索する').click
              expect(page).to have_content article.title
              expect(page).to have_content article.sub_title
              expect(page).to have_content article.user.name
            end

            it '中央一致する記事を返す' do
              fill_in 'input-author', with: '田太'
              find_button(text: '検索する').click
              expect(page).to have_content article.title
              expect(page).to have_content article.sub_title
              expect(page).to have_content article.user.name
            end

            it '後方一致する記事を返す' do
              fill_in 'input-author', with: '郎'
              find_button(text: '検索する').click
              expect(page).to have_content article.title
              expect(page).to have_content article.sub_title
              expect(page).to have_content article.user.name
            end
          end

          context '条件を満たすデータが存在しない場合' do
            it '投稿なしと表示される' do
              fill_in 'input-author', with: '存在しない名前'
              find_button(text: '検索する').click
              expect(page).to have_content '投稿なし'
              expect(page).not_to have_content article.title
            end
          end
        end

        context 'タイトルを入力' do
          it '完全一致する記事を返す' do
            fill_in 'input-title', with: 'RSpec'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end

          it '前方一致する記事を返す' do
            fill_in 'input-title', with: 'RSp'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end

          it '中央一致する記事を返す' do
            fill_in 'input-title', with: 'Spe'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end

          it '後方一致する記事を返す' do
            fill_in 'input-title', with: 'pec'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end
        end

        context 'サブタイトルを入力' do
          it '完全一致する記事を返す' do
            fill_in 'input-subtitle', with: 'system'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end

          it '前方一致する記事を返す' do
            fill_in 'input-subtitle', with: 'sys'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end

          it '中央一致する記事を返す' do
            fill_in 'input-subtitle', with: 'ste'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end

          it '後方一致する記事を返す' do
            fill_in 'input-subtitle', with: 'tem'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end
        end

        context '本文' do
          it '完全一致する記事を返す' do
            fill_in 'input-content', with: 'test'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end

          it '完全一致する記事を返す' do
            fill_in 'input-content', with: 'tes'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end

          it '完全一致する記事を返す' do
            fill_in 'input-content', with: 'es'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end

          it '完全一致する記事を返す' do
            fill_in 'input-content', with: 'est'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
            expect(page).to have_content article.user.name
          end
        end

        context '投稿日時で絞り込む' do
          before(:each) do
            article_2.update(created_at: '2022-01-01')
            visit current_path
            find_button(text: '絞り込み検索').click
          end

          context '指定開始日' do
            context 'テスト当日に指定した場合' do
              before(:each) do
                find('#input-start').set(Date.current)
                find_button(text: '検索する').click
              end

              it '指定範囲の記事が表示される' do
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.user.name
              end

              it '指定範囲外の記事は表示されない' do
                expect(page).not_to have_content article_2.title
                expect(page).not_to have_content article_2.sub_title
                expect(page).not_to have_content article_2.user.name
              end
            end

            context '2022-01-02に指定した場合（境界値・翌日）' do
              before(:each) do
                find('#input-start').set('02/01/2022')
                find_button(text: '検索する').click
              end

              it 'aritcle_2(created_at:2022-01-01)の記事が表示されない' do
                expect(page).not_to have_content article_2.title
                expect(page).not_to have_content article_2.sub_title
                expect(page).not_to have_content article_2.user.name
              end

              it '指定開始日からテスト当日までの記事が表示される' do
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.user.name
              end
            end

            context '2022-01-01に指定した場合' do
              it '指定開始日からテスト当日までの記事が表示される' do
                find('#input-start').set('01/01/2022')
                find_button(text: '検索する').click
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.user.name
                expect(page).to have_content article_2.title
                expect(page).to have_content article_2.sub_title
                expect(page).to have_content article_2.user.name
              end
            end

            context '2021-12-31に指定した場合（境界値・前日）' do
              it '指定開始日からテスト当日までの記事が表示される' do
                find('#input-start').set('31/12/2021')
                find_button(text: '検索する').click
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.user.name
                expect(page).to have_content article_2.title
                expect(page).to have_content article_2.sub_title
                expect(page).to have_content article_2.user.name
              end
            end

            context '指定範囲に記事が存在しない場合' do
              before(:each) do
                article.update(created_at: '2022-01-01')
                visit current_path
                find_button(text: '絞り込み検索').click
                find('#input-start').set(Date.current)
                find_button(text: '検索する').click
              end

              it '投稿なしと表示される' do
                expect(page).to have_content '投稿なし'
              end

              it '記事は表示されない' do
                expect(page).not_to have_content article.title
                expect(page).not_to have_content article_2.title
              end

              it 'リセットボタンが表示される' do
                expect(page).to have_button('リセット')
              end

              it 'リセットボタン押下で記事一覧が再表示される' do
                find_button(text: 'リセット').click
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.user.name
                expect(page).to have_content article_2.title
                expect(page).to have_content article_2.sub_title
                expect(page).to have_content article_2.user.name
              end
            end
          end

          context '指定終了日' do
            context 'テスト当日に指定した場合' do
              before(:each) do
                find('#input-finish').set(Date.current)
                find_button(text: '検索する').click
              end

              it '指定範囲の記事が表示される' do
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.user.name
                expect(page).to have_content article_2.title
                expect(page).to have_content article_2.sub_title
                expect(page).to have_content article_2.user.name
              end
            end

            context '2022-01-02に指定した場合（境界値・翌日）' do
              before(:each) do
                find('#input-finish').set('01/02/2022')
                find_button(text: '検索する').click
              end

              it '指定範囲の記事が表示される' do
                expect(page).to have_content article_2.title
                expect(page).to have_content article_2.sub_title
                expect(page).to have_content article_2.user.name
              end

              it '指定範囲外の記事は表示されない' do
                expect(page).not_to have_content article.title
                expect(page).not_to have_content article.sub_title
                expect(page).not_to have_content article.user.name
              end
            end

            context '2022-01-01に指定した場合（当日テスト）' do
              before(:each) do
                find('#input-finish').set('01/01/2022')
                find_button(text: '検索する').click
              end

              it '指定範囲の記事が表示される' do
                expect(page).to have_content article_2.title
                expect(page).to have_content article_2.sub_title
                expect(page).to have_content article_2.user.name
              end

              it '指定範囲外の記事は表示されない' do
                expect(page).not_to have_content article.title
                expect(page).not_to have_content article.sub_title
                expect(page).not_to have_content article.user.name
              end
            end

            context '2021-012-31に指定した場合（境界値・前日）' do
              before(:each) do
                visit current_path
                find_button(text: '絞り込み検索').click
                find('#input-finish').set('31/12/2021')
                find_button(text: '検索する').click
              end

              it '投稿なしと表示される' do
                expect(page).to have_content '投稿なし'
                expect(page).not_to have_content article.title
                expect(page).not_to have_content article_2.title
              end

              it '記事は表示されない' do
                expect(page).not_to have_content article.title
                expect(page).not_to have_content article_2.title
              end

              it 'リセットボタンが表示される' do
                expect(page).to have_button('リセット')
              end

              it 'リセットボタン押下で記事一覧が再表示される' do
                find_button(text: 'リセット').click
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.user.name
                expect(page).to have_content article_2.title
                expect(page).to have_content article_2.sub_title
                expect(page).to have_content article_2.user.name
              end
            end
          end

          context '指定開始日・終了日、両方を指定' do
            before(:each) do
              find('#input-start').set('01/02/2022')
              find('#input-finish').set(Date.current)
              find_button(text: '検索する').click
            end

            it '指定範囲の記事が表示される' do
              expect(page).to have_content article.title
              expect(page).to have_content article.sub_title
              expect(page).to have_content article.user.name
            end

            it '指定範囲外の記事は表示されない' do
              expect(page).not_to have_content article_2.title
              expect(page).not_to have_content article_2.sub_title
              expect(page).not_to have_content article_2.user.name
            end
          end
        end
      end
    end
  end

  describe '投稿した記事一覧画面' do # dashboard
    before(:each) do
      article_2.update(created_at: Time.current + 1.minute)
      visit users_dash_boards_path
    end

    it '現在のパスが記事一覧画面のパスである' do
      expect(page).to have_current_path users_dash_boards_path, ignore_query: true
    end

    describe '表示テスト' do
      it '画面の見出しに投稿した記事一覧が表示される' do
        expect(page).to have_selector('h1', text: '投稿した記事一覧')
      end

      it '正しいテーブルヘッダーが表示されていること' do
        expect(page).to have_selector('th', text: 'タイトル')
        expect(page).to have_selector('th', text: 'サブタイトル')
        expect(page).to have_selector('th', text: '投稿日時')
      end

      it 'ログインユーザーが投稿した記事のみ、一覧表示される' do
        expect(page).to have_content article.title
        expect(page).to have_content article.sub_title
        expect(page).to have_content article.created_at.strftime('%Y/%m/%d %H:%M')
      end

      it 'ログインユーザー以外の記事は表示されない' do
        expect(page).not_to have_content article_2.title
        expect(page).not_to have_content article_2.sub_title
        # expect(page).not_to have_content article_2.created_at.strftime('%Y/%m/%d %H:%M')
      end

      context '３点リーダー' do
        it '全ての記事に３点リーダーが表示されている' do
          expect(page.all('button', text: '︙').count).to eq 1
        end

        context '３点リーダー押下' do
          before(:each) do
            page.all(:button, '︙')[0].click
          end

          it '閲覧・編集・削除ボタンが表示される' do
            expect(page).to have_content('閲覧')
            expect(page).to have_content('編集')
            expect(page).to have_content('削除')
          end
        end
      end

      context 'ページネーション' do
        before(:each) do
          article_30
          visit current_path
        end

        it '最下部にページ割で表示される' do
          page.execute_script('window.scroll(0, 1000)') # ページ割部分まで下へスクロール
          expect(page).to have_selector '.pagination' # 不要なテストかも
          expect(page).to have_selector('.article-paginate') # 不要なテストかも
          expect(page).to have_link('1', class: 'page-link')
          expect(page).to have_link('2', class: 'page-link')
          expect(page).to have_link('›', class: 'page-link')
          expect(page).to have_link('»', class: 'page-link')
          # expect(page).to have_link('...', class: 'page-link') 5ページ以上から...が表示される
        end
      end

      context '並べ替えボタン' do
        it '表示されている' do
          expect(page).to have_button('並べ替え')
        end

        context '並べ替えボタン押下' do
          it 'モーダルが表示される' do
            find_button(text: '並べ替え').click
            expect(page).to have_css('.modal.fade.show')
            expect(page).to have_css('.modal-title', text: '並べ替え')
            expect(page).to have_content '投稿日時'
            expect(page).to have_select('sort-select')
            find_field('sort-select').click
            expect(page).to have_select('sort-select', selected: '新しい順')
            expect(page).to have_select('sort-select', text: '古い順')
            expect(page).to have_button '並べ替える'
            expect(page).to have_button '戻る'
          end
        end
      end

      context '絞り込み検索ボタン' do
        it '表示されている' do
          expect(page).to have_button('絞り込み検索')
        end

        context '絞り込み検索ボタン押下' do
          it 'モーダルが表示される' do
            find_button(text: '絞り込み検索').click
            expect(page).to have_css('.modal.fade.show')
            expect(page).to have_css('.modal-title', text: '絞り込み検索')
            expect(page).to have_content 'タイトル'
            expect(page).to have_selector('input#input-title')
            expect(page).to have_content 'サブタイトル'
            expect(page).to have_selector('input#input-subtitle')
            expect(page).to have_content '本文'
            expect(page).to have_selector('input#input-content')
            expect(page).to have_content '投稿日時'
            expect(page).to have_selector('input#input-start[type="date"]')
            expect(page).to have_selector('input#input-finish[type="date"]')
            expect(page).to have_button '検索する'
            expect(page).to have_button '戻る'
          end
        end
      end
    end

    describe '遷移テスト' do
      context '記事のタイトルを押下' do
        before(:each) do
          find('#article-title', text: article.title).click
        end

        it '記事詳細画面へ遷移する' do
          expect(page).to have_current_path users_article_path(article), ignore_query: true
          expect(page).to have_content article.title
          expect(page).to have_content article.sub_title
          expect(page).to have_content article.content
        end

        it '編集・削除ボタンが表示される' do
          expect(page).to have_content('編集')
          expect(page).to have_content('削除')
        end
      end

      context '記事のサブタイトルを押下' do
        before(:each) do
          find('#article-subtitle', text: article.sub_title).click
        end

        it '記事詳細画面へ遷移する' do
          expect(page).to have_current_path users_article_path(article), ignore_query: true
          expect(page).to have_content article.title
          expect(page).to have_content article.sub_title
          expect(page).to have_content article.content
        end

        it '編集・削除ボタンが表示される' do
          expect(page).to have_content('編集')
          expect(page).to have_content('削除')
        end
      end

      context '記事の投稿日時を押下' do
        before(:each) do
          find('#article-createdat', text: article.created_at.strftime('%Y/%m/%d %H:%M')).click
        end

        it '記事詳細画面へ遷移する' do
          expect(page).to have_current_path users_article_path(article), ignore_query: true
          expect(page).to have_content article.title
          expect(page).to have_content article.sub_title
          expect(page).to have_content article.content
        end

        it '編集・削除ボタンが表示される' do
          expect(page).to have_content('編集')
          expect(page).to have_content('削除')
        end
      end

      context '３点リーダー' do
        before(:each) do
          page.all('.btn', text: '︙')[0].click
        end

        context '閲覧ボタン押下' do
          before(:each) do
            find_link('閲覧').click
            # sleep 1 # ないと時々エラー
          end

          it '記事詳細画面へ遷移する' do
            expect(page).to have_current_path users_article_path(article), ignore_query: true
            expect(page).to have_content(article.title) # ページ遅延エラー対策
            expect(page).to have_content(article.sub_title)
            expect(page).to have_content(article.content, wait: 10)
          end

          it '編集・削除ボタンが表示される' do
            expect(page).to have_content('編集', wait: 10)
            expect(page).to have_content('削除')
          end
        end

        context '編集ボタン押下' do
          before(:each) do
            click_link '編集'
          end

          it '編集ボタン押下で記事詳細画面へ遷移する' do
            expect(page).to have_current_path edit_users_article_path(article), ignore_query: true
            expect(page).to have_field('article_title', with: article.title)
            expect(page).to have_field('article_sub_title', with: article.sub_title)
            expect(page).to have_field('article_content', with: article.content)
          end
        end
      end

      describe 'ページネーション' do
        before(:each) do
          article
          article_148 # 計150件
          visit current_path
          page.execute_script('window.scroll(0, 1000)')
        end

        it '1を押下で、1ページ目へ遷移する' do
          find('.page-link', text: '2').click
          page.execute_script('window.scroll(0, 1000)')
          # sleep 1
          # wait_for_ajax_without_jquery
          find('.page-link', text: '1').click
          # sleep 1
          page.execute_script('window.scroll(0, 1000)')
          sleep 1
          background_color = find_link('1').native.css_value('background-color')
          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
        end

        it '3を押下で、3ページ目へ遷移する' do
          find('.page-link', text: '3').click
          page.execute_script('window.scroll(0, 1000)')
          # sleep 1
          sleep 1
          background_color = find('.page-link', text: '3').native.css_value('background-color')
          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_selector('a', text: '3', class: 'page-link')
        end

        it '5を押下で、5ページ目へ遷移する' do
          find('.page-link', text: '5').click
          page.execute_script('window.scroll(0, 1000)')
          # sleep 1
          sleep 1
          background_color = find_link('5').native.css_value('background-color')

          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # sleep 2
          # expect(page).to have_selector('a', text: '5', class: 'page-link')
        end

        it '›を押下で、次のページへ遷移する' do
          find('.page-link', text: '›').click
          page.execute_script('window.scroll(0, 1000)')
          sleep 1
          background_color = find_link('2').native.css_value('background-color')

          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_selector('a', text: '2', class: 'page-link')
        end

        it '»を押下で、最終ページへ遷移する' do
          find('.page-link', text: '»').click
          page.execute_script('window.scroll(0, 1000)')
          sleep 1
          background_color = find_link('5').native.css_value('background-color')

          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_selector('a', text: '5', class: 'page-link')
          expect(page).not_to have_selector('a', text: '»', class: 'page-link')
        end

        it '‹を押下で、前のページへ遷移する' do
          find('.page-link', text: '»').click
          page.execute_script('window.scroll(0, 1000)')
          # sleep 1
          # wait_for_ajax_without_jquery
          find('.page-link', text: '‹').click
          page.execute_script('window.scroll(0, 1000)')
          sleep 1
          background_color = find_link('4').native.css_value('background-color')
          expect(background_color).to eq 'rgba(13, 110, 253, 1)'
          # expect(page).to have_selector('a', text: '4', class: 'page-link')
        end

        it '«を押下で、最初のページへ遷移する' do
          find('.page-link', text: '»').click
          page.execute_script('window.scroll(0, 1000)')
          sleep 1
          find('.page-link', text: '«').click
          page.execute_script('window.scroll(0, 1000)')
          sleep 2
          background_color = find('.page-link', text: '1').native.css_value('background-color')
          expect(background_color).to eq 'rgba(13, 110, 253, 1)'

          expect(page).not_to have_selector('.page-link', text: '«', class: 'page-link')
        end
      end
    end

    context '機能テスト' do
      it '３点リーダーから記事の削除ができる' do
        article_first = Article.first.id
        page.all('.btn', text: '︙')[0].click # click_link '︙', match: :first は ×
        # click_link '削除'
        find_link('削除').click
        expect {
          expect(page.accept_confirm).to eq '選択した記事を削除します。'
          expect(page).to have_content('記事を削除しました。', wait: 5)
        }.to change(user.articles, :count).by(-1)
        expect(page).not_to have_content article.title
        expect(page).not_to have_content article.sub_title
        expect(page).not_to have_content article.user.name
        expect(Article.exists?(article_first)).to be_falsey
        # sleep 1
      end

      context '並べ替えボタン' do
        before(:each) do
          article_30
          visit current_path
        end

        context '新しい順を選択' do
          it '降順になる' do
            find_button(text: '並べ替え').click
            # find('.form-select').click
            find('.form-select', text: '新しい順').click
            find_button(text: '並べ替える').click
            expect(find('#article-title', match: :first).text).to eq Article.last.title
          end
        end

        context '古い順を選択' do
          it '昇順になる' do
            find_button(text: '並べ替え').click
            # find('.form-select').click
            find('.form-select option[value="ASC"]').click
            find_button(text: '並べ替える').click
            # sleep 3
            expect(find('#article-title', match: :first).text).to eq Article.first.title
          end
        end
      end

      context '絞り込み検索ボタン' do
        let(:user_article_2) { create(:article, user: user) }

        before(:each) do
          # Article.create(title:'アール', sub_title:'スペック', content:'システム', user: user)
          user_article_2
          article_1
          visit current_path
          find_button(text: '絞り込み検索').click
        end

        context 'タイトルを入力' do
          it '完全一致する記事を返す' do
            fill_in 'input-title', with: 'RSpec'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end

          it '前方一致する記事を返す' do
            fill_in 'input-title', with: 'RSp'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end

          it '中央一致する記事を返す' do
            fill_in 'input-title', with: 'Spe'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end

          it '後方一致する記事を返す' do
            fill_in 'input-title', with: 'pec'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end

          it 'ログインユーザー以外の記事は抽出されない' do
            Article.first.destroy # ログインユーザーの投稿記事を削除
            fill_in 'input-title', with: article_1.title
            find_button(text: '検索する').click
            expect(page).to have_content '投稿なし'
            expect(page).not_to have_content article_1.title
            expect(page).not_to have_content article_1.sub_title
          end
        end

        context 'サブタイトルを入力' do
          it '完全一致する記事を返す' do
            fill_in 'input-subtitle', with: 'system'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end

          it '前方一致する記事を返す' do
            fill_in 'input-subtitle', with: 'sys'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end

          it '中央一致する記事を返す' do
            fill_in 'input-subtitle', with: 'ste'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end

          it '後方一致する記事を返す' do
            fill_in 'input-subtitle', with: 'tem'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end
        end

        context '本文' do
          it '完全一致する記事を返す' do
            fill_in 'input-content', with: 'test'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end

          it '前方一致する記事を返す' do
            fill_in 'input-content', with: 'te'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end

          it '中央一致する記事を返す' do
            fill_in 'input-content', with: 'es'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end

          it '後方一致する記事を返す' do
            fill_in 'input-content', with: 'st'
            find_button(text: '検索する').click
            expect(page).to have_content article.title
            expect(page).to have_content article.sub_title
          end
        end

        context '投稿日時で絞り込む' do
          before(:each) do
            user_article_2.update(created_at: '2022-01-01')
            # sleep 1
            # find_button(text: '絞り込み検索').click
          end

          context '指定開始日' do
            context 'テスト当日に指定した場合' do
              before(:each) do
                find('#input-start').set(Date.current)
                find_button(text: '検索する').click
              end

              it '指定範囲の記事が表示される' do
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
              end

              it '指定範囲外の記事は表示されない' do
                expect(page).not_to have_content user_article_2.title
                expect(page).not_to have_content user_article_2.sub_title
                expect(page).not_to have_content user_article_2.created_at.strftime('%Y/%m/%d %H:%M')
              end
            end

            context '2022-01-02に指定した場合（境界値・翌日）' do
              before(:each) do
                find('#input-start').set('02/01/2022')
                find_button(text: '検索する').click
              end

              it '2022-01-01投稿の記事は表示されない' do
                expect(page).not_to have_content user_article_2.title
                expect(page).not_to have_content user_article_2.sub_title
                expect(page).not_to have_content user_article_2.created_at.strftime('%Y/%m/%d %H:%M')
              end

              it '指定範囲の記事が表示される' do
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
              end
            end

            context '2022-01-01に指定した場合（当日テスト）' do
              it '指定日範囲の記事が表示される' do
                find('#input-start').set('01/01/2022')
                find_button(text: '検索する').click
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.created_at.strftime('%Y/%m/%d %H:%M')

                expect(page).to have_content user_article_2.title
                expect(page).to have_content user_article_2.sub_title
                expect(page).to have_content user_article_2.created_at.strftime('%Y/%m/%d %H:%M')
              end
            end

            context '2021-12-31に指定した場合（境界値・前日）' do
              it '指定日範囲の記事が表示される' do
                find('#input-start').set('31/12/2021')
                find_button(text: '検索する').click
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.created_at.strftime('%Y/%m/%d %H:%M')

                expect(page).to have_content user_article_2.title
                expect(page).to have_content user_article_2.sub_title
                expect(page).to have_content user_article_2.created_at.strftime('%Y/%m/%d %H:%M')
              end
            end

            context '指定範囲に記事が存在しない場合' do
              before(:each) do
                article.update(created_at: '2022-01-01')
                visit current_path
                find_button(text: '絞り込み検索').click
                find('#input-start').set(Date.current)
                find_button(text: '検索する').click
              end

              it '投稿なしと表示される' do
                expect(page).to have_content '投稿なし'
              end

              it '記事は表示されない' do
                expect(page).not_to have_content article.title
                expect(page).not_to have_content user_article_2.title
              end

              it 'リセットボタンが表示される' do
                expect(page).to have_button('リセット')
              end

              it 'リセットボタン押下で記事一覧が再表示される' do
                find_button(text: 'リセット').click
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.created_at.strftime('%Y/%m/%d %H:%M')

                expect(page).to have_content user_article_2.title
                expect(page).to have_content user_article_2.sub_title
                expect(page).to have_content user_article_2.created_at.strftime('%Y/%m/%d %H:%M')
              end
            end
          end

          context '指定終了日' do
            context 'テスト当日に指定した場合' do
              before(:each) do
                find('#input-finish').set(Date.current)
                find_button(text: '検索する').click
              end

              it '指定範囲の記事が表示される' do
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.created_at.strftime('%Y/%m/%d %H:%M')
                expect(page).to have_content user_article_2.title
                expect(page).to have_content user_article_2.sub_title
                expect(page).to have_content user_article_2.created_at.strftime('%Y/%m/%d %H:%M')
              end
            end

            context '2022-01-02に指定した場合（境界値・翌日）' do
              before(:each) do
                find('#input-finish').set('01/02/2022')
                find_button(text: '検索する').click
              end

              it '指定範囲の記事が表示される' do
                expect(page).to have_content user_article_2.title
                expect(page).to have_content user_article_2.sub_title
                expect(page).to have_content user_article_2.created_at.strftime('%Y/%m/%d %H:%M')
              end

              it '指定範囲外の記事は表示されない' do
                expect(page).not_to have_content article.title
                expect(page).not_to have_content article.sub_title
                expect(page).not_to have_content article.created_at.strftime('%Y/%m/%d %H:%M')
              end
            end

            context '2022-01-01に指定した場合（当日テスト）' do
              before(:each) do
                find('#input-finish').set('01/01/2022')
                find_button(text: '検索する').click
              end

              it '指定範囲の記事が表示される' do
                expect(page).to have_content user_article_2.title
                expect(page).to have_content user_article_2.sub_title
                expect(page).to have_content user_article_2.created_at.strftime('%Y/%m/%d %H:%M')
              end

              it '指定範囲外の記事は表示されない' do
                expect(page).not_to have_content article.title
                expect(page).not_to have_content article.sub_title
                expect(page).not_to have_content article.created_at.strftime('%Y/%m/%d %H:%M')
              end
            end

            context '2021-012-31に指定した場合（境界値・前日）' do
              before(:each) do
                visit current_path
                find_button(text: '絞り込み検索').click
                find('#input-finish').set('31/12/2021')
                find_button(text: '検索する').click
              end

              it '投稿なしと表示される' do
                expect(page).to have_content '投稿なし'
                expect(page).not_to have_content article.title
                expect(page).not_to have_content user_article_2.title
              end

              it '記事は表示されない' do
                expect(page).not_to have_content article.title
                expect(page).not_to have_content user_article_2.title
              end

              it 'リセットボタンが表示される' do
                expect(page).to have_button('リセット')
              end

              it 'リセットボタン押下で記事一覧が再表示される' do
                find_button(text: 'リセット').click
                expect(page).to have_content article.title
                expect(page).to have_content article.sub_title
                expect(page).to have_content article.created_at.strftime('%Y/%m/%d %H:%M')
                expect(page).to have_content user_article_2.title
                expect(page).to have_content user_article_2.sub_title
                expect(page).to have_content user_article_2.created_at.strftime('%Y/%m/%d %H:%M')
              end
            end
          end

          context '指定開始日・終了日、両方を指定' do
            before(:each) do
              find('#input-start').set('01/02/2022')
              find('#input-finish').set(Date.current)
              find_button(text: '検索する').click
            end

            it '指定範囲の記事が表示される' do
              expect(page).to have_content article.title
              expect(page).to have_content article.sub_title
              expect(page).to have_content article.created_at.strftime('%Y/%m/%d %H:%M')
            end

            it '指定範囲外の記事は表示されない' do
              expect(page).not_to have_content user_article_2.title
              expect(page).not_to have_content user_article_2.sub_title
              expect(page).not_to have_content user_article_2.created_at.strftime('%Y/%m/%d %H:%M')
            end
          end
        end
      end
    end
  end

  describe '画面遷移のテスト' do # redirect to #X
    context '記事一覧画面と投稿した記事一覧画面' do # X = index || dashboards
      after(:each) do # 記事一覧画面と投稿した記事一覧画面の共通項目テスト after(:each) doの略称
        expect(page).to have_content 'タイトル'
        expect(page).to have_content 'サブタイトル'
        expect(page).to have_content '投稿日'

        expect(page).to have_content article.created_at.strftime('%Y/%m/%d %H:%M')
        expect(page).to have_content article.title
        expect(page).to have_content article.sub_title

        # expect(page).to have_button('︙')
        click_button('︙')
        expect(page).to have_link('閲覧')
        expect(page).to have_link('編集')
        expect(page).to have_link('削除')
      end

      context '記事一覧画面' do # index
        it '成功する' do # success
          visit users_articles_path
          expect(page).to have_current_path users_articles_path, ignore_query: true
          expect(page).to have_content '記事一覧'
          expect(page).to have_content '投稿者'
          expect(page).to have_content article.user.name
        end
      end

      context '投稿した記事一覧画面' do # dashboards
        it '成功する' do # success
          visit users_dash_boards_path
          expect(page).to have_current_path users_dash_boards_path, ignore_query: true
          expect(page).to have_content '投稿した記事一覧'
          expect(page).not_to have_content '投稿者'
          expect(page).not_to have_content article.user.name, count: 2
        end
      end
    end

    context '記事投稿画面または記事詳細画面' do # X = new || edit
      after(:each) do
        expect(page).to have_content 'エディター'
        expect(page).to have_content 'プレビュー'
        expect(page).to have_link 'キャンセル'
        expect(page).to have_css('.markdown-editor')
      end

      context '記事投稿画面' do # new
        it '成功する' do # success
          visit new_users_article_path
          expect(page).to have_current_path new_users_article_path, ignore_query: true
          expect(page).to have_content '記事投稿'
          expect(page).to have_button '投稿'
          # expect(page).to have_css('.markdown-editor', placeholder: '本文')
          expect(page).to have_field('article_title', placeholder: 'タイトル')
          expect(page).to have_field('article_sub_title', placeholder: 'サブタイトル')
          expect(page).to have_field('article_content', placeholder: '本文')
          # expect(page).to have_css('.markdown-editor')
        end
      end

      context 'edit' do
        it 'success' do
          visit edit_users_article_path(article)
          expect(page).to have_current_path edit_users_article_path(article), ignore_query: true
          expect(page).to have_content '記事編集'
          expect(page).to have_button '更新'
          expect(page).to have_field('article_title', with: article.title)
          expect(page).to have_field('article_sub_title', with: article.sub_title)
          expect(page).to have_field('article_content', with: article.content)
          expect(page).to have_content article.content, count: 2 # ページ内で、article.contentの呼び出しが計2回ある
        end
      end
    end

    context 'X = show' do
      after(:each) do
        expect(page).to have_current_path users_article_path(article), ignore_query: true
        expect(page).to have_content article.title
        expect(page).to have_content article.sub_title
        expect(page).to have_content article.content
      end

      context 'writer' do
        it 'success' do
          visit users_article_path(article)
          expect(page).to have_content '編集'
          expect(page).to have_content '削除'
          expect(page).not_to have_content article.user.name, count: 2
        end
      end

      context 'non_writer' do
        it 'success' do
          find('#dropdownMenuButton').click # dropdownmenu を探してクリック
          click_link 'ログアウト' # click_button ×
          sign_in(user_2)
          visit users_article_path(article)
          expect(page).not_to have_content '編集'
          expect(page).not_to have_content '削除'
          expect(page).to have_content '投稿者'
          expect(page).to have_content article.user.name
        end
      end
    end
  end

  describe 'create article' do
    it 'success' do
      visit new_users_article_path
      fill_in 'article[title]', with: 'title'
      fill_in 'article[sub_title]', with: 'sub_title'
      fill_in 'article[content]', with: 'content'
      click_button '投稿'
      expect(page).to have_current_path users_article_path(Article.last), ignore_query: true
      expect(page).to have_content '記事を作成しました。'
    end

    it 'failure' do
      visit new_users_article_path
      click_button '投稿'
      expect(page).to have_content '記事の作成に失敗しました。'
    end
  end

  describe 'edit article' do
    it 'success' do
      visit edit_users_article_path(article)
      prev_article_title = article.title
      fill_in 'article[title]', with: 'たいとる'
      fill_in 'article[sub_title]', with: 'さぶたいとる'
      fill_in 'article[content]', with: 'こんてんつ'
      click_button '更新'
      article.reload
      expect(page).to have_current_path users_article_path(article), ignore_query: true
      expect(page).to have_content '記事を編集しました。'
      expect(page).to have_content article.title

      expect(page).not_to have_content prev_article_title
    end

    it 'failure' do
      visit edit_users_article_path(article)
      fill_in 'article[title]', with: nil
      click_button '更新'
      expect(page).to have_content '記事の編集に失敗しました。'
      expect(page).not_to have_content article.title
    end
  end

  describe 'delete article' do
    context 'dashboards to delete' do
      it 'success' do
        visit users_dash_boards_path
        expect(page).to have_content article.title
        # page.find('.link-tr', text: article.title).click
        page.first('.link-td', text: article.title).click
        expect(page).to have_current_path users_article_path(article), ignore_query: true
        page.accept_confirm('表示中の記事を削除します。') do
          click_link '削除'
        end
        expect(page).to have_content '記事を削除しました。'
        expect(page).to have_current_path users_dash_boards_path(user), ignore_query: true
        expect(page).not_to have_content article.title
      end
    end

    context 'index to delete' do
      it 'success' do
        visit users_articles_path
        expect(page).to have_content article.title
        page.first('.link-td', text: article.title).click
        expect(page).to have_current_path users_article_path(article), ignore_query: true
        page.accept_confirm('表示中の記事を削除します。') do
          click_link '削除'
        end
        expect(page).to have_content '記事を削除しました。'
        expect(page).to have_current_path users_articles_path, ignore_query: true
        expect(page).not_to have_content article.title
      end
    end
  end

  describe 'markdown with marked.js', js: true do # Marked.js によるマークダウン
    before(:each) do
      article.content = "# This is h1.  \r\n```ruby:qiita.rb\r\nputs 'The best way to log and share programmers knowledge.'\r\n```"
      article.save
    end

    describe 'new article page' do # 記事投稿画面で
      before(:each) do
        visit new_users_article_path
        sleep 1
        @markd = find('.markdown-editor')
        @preview = find('.preview')
      end

      it 'markdown to preview' do # プレビュー画面でマークダウンが機能している
        @markd.set(article.content)
        expect(@preview).to have_css('h1', text: 'This is h1.', wait: 1) # 「#」の文字列が、h1のcssになっていることを期待
      end

      it 'drag and drop image' do
        img = file_fixture('ruby.png')
        @markd.drop(img)
        page.save_screenshot 'rubyロゴ画像添付.png'
        expect(@preview).to have_css('img[alt="ruby.png"]', wait: 1)
        expect(@markd.value).to start_with '<img alt="ruby.png"'
      end

      it 'to code block' do
        @markd.set(article.content)
        page.save_screenshot 'newページのコードブロック.png'
        expect(@preview).to have_selector('.code-frame', visible: true)
        frame = @preview.find('.code-frame')
        expect(frame).to match_style({ "background-color": 'rgba(54, 69, 73, 1)' })
        expect(frame).to have_selector('.code-ref', visible: true)
        expect(frame).to have_css('.code-ref', text: 'qiita.rb', visible: true)
        expect(frame).to have_css('code', text: "puts 'The best way to log and share programmers knowledge.'", visible: true)
      end
    end

    describe 'show article page' do
      it 'code copy' do
        visit users_article_path(article)
        page.execute_script("
          $('.container').append('<button class=\"copybtn\">コードコピー</button>')
          $('.container').append('<textarea class=\"paste\"></textarea>')
        ")
        wait_for_ajax
        expect(page).to have_css('.copybtn', text: 'コードコピー', visible: true)
        expect(page).to have_css('.paste', visible: true)
        page.execute_script("
          $('.copybtn').click(function(){
            var pre = $('.code-copy').next('.highlight').find('pre');
            navigator.permissions.query({name:\"clipboard-write\"}).then(permissionStatus => { if(permissionStatus.state == \"prompt\") { permissionStatus.prompt(); } })
            navigator.clipboard.writeText(pre.contents().text()).then(
              function(){
                $('.copybtn').text(pre.contents().text())
              },
              function(){
                $('.copybtn').text('error')
                $('.container').append($('.paste').clone())
              }
            );
            $('.paste').val(navigator.clipboard.readText());
          })
        ")
        find('.copybtn').click
        wait_for_ajax
        page.accept_confirm do
          page.save_screenshot '記事詳細copy.png'
          expect(find('.copybtn').text).not_to eq 'コードコピー'
          expect(page).to have_css('.copybtn', text: 'コードコピー', visible: false)
          page.execute_script("$('.paste').val(navigator.clipboard.readText())")
          expect(find('.paste').value).to eq 'コピー成功'
        end
        page.driver.browser.execute_script('navigator.permissions.query({name:"clipboard-write"}).then(permissionStatus => { if(permissionStatus.state == "prompt") { permissionStatus.prompt(); } })')

        # expect(page).to have_css('.clipboard', visible: true)
        # page.find('.clipboard').click
        # expect(page).to have_css('.messe', text: 'Copied!', visible: true)
        # page.execute_script("$('.container').append('<textarea></textarea>')")
        # copy_text = 'Copied Text'
        # page.execute_script("navigator.clipboard.writeText('#{copy_text}')")
        # textarea = find('textarea')
        # copied_text = page.execute_script("return navigator.clipboard.readText()")
        # expect(copied_text).to eq 1
        # expect(page.evaluate_script('navigator.clipboard.readText()')).to eq 'Some text to copy'
      end
    end
  end
end

# 以下、参考コードのため終わり次第の削除
# page.save_screenshot '記事投稿.png'
# page.execute_script <<-JS
#   dataTransfer = new DataTransfer()
#   dataTransfer.files.add(fakeFileInput.get(0).files[0])
#   testEvent = new DragEvent('drop', {bubbles:true, dataTransfer: dataTransfer })
#   $('.markdown-editor').dispatchEvent(testEvent)
# JS
