require 'rails_helper'

RSpec.describe 'Articles', type: :system do
  let(:user_a) { create(:user, :a, confirmed_at: Date.today) }
  let(:user_b) { create(:user, :b, confirmed_at: Date.today) }
  let(:article_a) { create(:article, user: user_a) }
  let(:article_b) { create(:article, user: user_b) }

  before do
    sign_in(user_a)
    article_a
  end

  describe '記事一覧画面' do # index
    before do
      article_b
      visit users_articles_path
    end

    it '記事一覧画面に遷移できる' do
      expect(current_path).to eq users_articles_path
    end

    describe '表示テスト' do
      
      it '全ての記事が一覧表示される' do
        # 確認すべき内容を配列でまとめて、eachで回す
        [article_a, article_b].each do |article|
          expect(page).to have_content article.title
          expect(page).to have_content article.sub_title
          expect(page).to have_content article.user.name
          expect(page).to have_content article.created_at.strftime('%Y/%m/%d %H:%M')
        end
        expect(page).to have_button('︙')
      end

      describe '３点リーダー' do
        context 'ログインユーザーの記事' do
          it '閲覧・編集・削除ボタンが表示される' do
            page.all(:button, '︙')[1].click # 一覧の2つ目がログインユーザー（user_a）の記事
            expect(page).to have_content('閲覧')
            expect(page).to have_content('編集')
            expect(page).to have_content('削除')
          end
        end
        
        context 'ログインユーザー以外の記事' do
          it '閲覧ボタンのみ表示される' do
            # click_button '︙', match: :first もOK
            # find('button', text: '︙', match: :first).click もOK
            # page.all(:button, '︙')[0].click もOK
            find_button( '︙', match: :first).click
            expect(page).to have_content('閲覧')
            expect(page).not_to have_content('編集')
            expect(page).not_to have_content('削除')
          end
        end
      end
    end

    describe '遷移テスト' do
      context 'ログインユーザーの記事押下' do
        before do
          find('.link-td', text: article_a.sub_title).click
        end

        it '記事詳細画面へ遷移する' do
          expect(current_path).to eq users_article_path(article_a)
          expect(page).to have_content article_a.title
          expect(page).to have_content article_a.sub_title
          expect(page).to have_content article_a.content
        end
        
        it '編集・削除ボタンが表示される' do
          expect(page).to have_content('編集')
          expect(page).to have_content('削除')
        end
      end
      
      context 'ログインユーザー以外の記事押下' do
        before do
          find('.link-td', text: article_b.sub_title).click
        end

        it '記事詳細画面へ遷移する' do
          expect(current_path).to eq users_article_path(article_b)
          expect(page).to have_content article_b.title
          expect(page).to have_content article_b.sub_title
          expect(page).to have_content article_b.content
          expect(page).to have_content user_b.name
        end

        it '編集・削除ボタンが表示されない' do
          expect(page).to_not have_content('編集')
          expect(page).to_not have_content('削除')
        end
      end
      
      context 'ログインユーザーの記事の３点リーダー' do # この箇所で、高速テストの影響で、不安定なエラー発生する！解決案は, wait: 10 か、sleep 1
        before do
          page.all('.btn', text: '︙')[1].click # 2番目を押下
          #click_button '︙', match: :first 1番目を押下、この記述だと２番目以降を押下指定する実装不可
        end
        
        context '閲覧ボタン押下' do
          before do
            #binding.pry
            #click_link '閲覧'
            #find('a.nav-link', text: '閲覧').click
            find_link('閲覧').click
            #sleep 1 # ないと時々エラー
          end

          it '記事詳細画面へ遷移する' do
            expect(current_path).to eq users_article_path(article_a)
            expect(page).to have_content(article_a.title) # ページ遅延エラー対策
            expect(page).to have_content(article_a.sub_title)
            expect(page).to have_content(article_a.content, wait: 10)
          end
          
          it '編集・削除ボタンが表示される' do
            expect(page).to have_content('編集', wait: 10)
            expect(page).to have_content('削除')
          end
        end
        
        context '編集ボタン押下' do
          before do
            click_link '編集'
          end

          it '編集ボタン押下で記事詳細画面へ遷移する' do
            expect(current_path).to eq edit_users_article_path(article_a)
            expect(page).to have_field('article_title', with: article_a.title)
            expect(page).to have_field('article_sub_title', with: article_a.sub_title)
            expect(page).to have_field('article_content', with: article_a.content)
          end
        end
      end
        
      context 'ログインユーザー以外の記事の３点リーダー、閲覧ボタン押下' do
        before do
          click_button '︙', match: :first #, visible: false
          click_link '閲覧'
          # sleep 1 これよりも , have_content オプションで wait: 10 が良いらしい
        end

        it '記事詳細画面へ遷移する' do
          expect(current_path).to eq users_article_path(article_b)
          expect(page).to have_content article_b.title # ページ遅延エラー対策
          expect(page).to have_content article_b.sub_title
          expect(page).to have_content article_b.content
          expect(page).to have_content user_b.name
        end

        it '編集・削除ボタンが表示されない' do
          expect(page).to_not have_content('編集')
          expect(page).to_not have_content('削除')
        end
      end
    end

    context '機能テスト' do
      it '３点リーダーから記事の削除ができる' do
        # ログインユーザーの記事の３点リーダーから削除ボタンを押下する
        
        article_first = Article.first.id
        page.all('.btn', text: '︙')[1].click # click_link '︙', match: :first は ×
        #click_link '削除'
        find_link('削除').click
        expect{
          expect(page.accept_confirm).to eq '選択した記事を削除します。' # accept_confirm はデフォルトで OK 押下する
          expect(page).to have_content('記事を削除しました。', wait: 10)
        }. to change(user_a.articles, :count).by(-1)
        expect(page).to_not have_content article_a.title
        expect(page).to_not have_content article_a.sub_title
        expect(page).to_not have_content article_a.user.name
        expect(Article.exists?(article_first)).to be_falsey  # DBに無い
        # expect(Article.where(id: article_first).count).to eq 0 # DBに無い
        #page.accept_confirm('選択した記事を削除します。') do # accept_confirm のデフォルトがOK押下する！
          #binding.pry
          #click_button "OK"
          #confirm
          #sleep 1 ここだとエラー！処理速度が速いせいで！
        #end
        # 記事が削除されていることを確認する
        #sleep 1
      end
    end
  end

  describe '画面遷移のテスト' do # redirect to #X
    context '記事一覧画面と投稿した記事一覧画面' do # X = index || dashboards
      context '記事一覧画面' do # index
        it '成功する' do # success
          visit users_articles_path
          expect(current_path).to eq users_articles_path
          expect(page).to have_content '記事一覧'
          expect(page).to have_content '投稿者'
          expect(page).to have_content article_a.user.name
        end
      end
    
      context '投稿した記事一覧画面' do # dashboards
        it '成功する' do # success
          visit users_dash_boards_path
          expect(current_path).to eq users_dash_boards_path
          expect(page).to have_content '投稿した記事一覧'
          expect(page).to_not have_content '投稿者'
          expect(page).to_not have_content article_a.user.name, count: 2
        end
      end

      after do # 記事一覧画面と投稿した記事一覧画面の共通項目テスト after(:each) doの略称
        expect(page).to have_content 'タイトル'
        expect(page).to have_content 'サブタイトル'
        expect(page).to have_content '投稿日'
        #binding.pry
        expect(page).to have_content article_a.created_at.strftime('%Y/%m/%d %H:%M')
        expect(page).to have_content article_a.title
        expect(page).to have_content article_a.sub_title
        # binding.pry
        #expect(page).to have_button('︙')
        click_button('︙')
        expect(page).to have_link('閲覧')
        expect(page).to have_link('編集')
        expect(page).to have_link('削除')
      end
    end

      
    context '記事投稿画面または記事詳細画面' do # X = new || edit
      context '記事投稿画面' do # new
        it '成功する' do # success
          visit new_users_article_path
          expect(current_path).to eq new_users_article_path
          expect(page).to have_content '記事投稿'
          expect(page).to have_button '投稿'
          #expect(page).to have_css('.markdown-editor', placeholder: '本文')
          expect(page).to have_field('article_title', placeholder: 'タイトル')
          expect(page).to have_field('article_sub_title', placeholder: 'サブタイトル')
          expect(page).to have_field('article_content', placeholder: '本文')
          # expect(page).to have_css('.markdown-editor')
        end
      end

      context 'edit' do
        it 'success' do
          visit edit_users_article_path(article_a)
          expect(current_path).to eq edit_users_article_path(article_a)
          expect(page).to have_content "記事編集"
          expect(page).to have_button '更新'
          expect(page).to have_field('article_title', with: article.title)
          expect(page).to have_field('article_sub_title', with: article.sub_title)
          expect(page).to have_field('article_content', with: article.content)
          expect(page).to have_content article_a.content, count: 2 # ページ内で、article.contentの呼び出しが計2回ある
        end
      end

      after do
        expect(page).to have_content 'エディター'
        expect(page).to have_content 'プレビュー'
        expect(page).to have_link 'キャンセル'
        expect(page).to have_css('.markdown-editor')
      end
    end

    context 'X = show' do
      context 'writer' do
        it 'success' do
          visit users_article_path(article_a)
          expect(page).to have_content '編集'
          expect(page).to have_content '削除'
          expect(page).to_not have_content article_a.user.name, count: 2
        end
      end

      context 'non_writer' do
        it 'success' do
          find('#dropdownMenuButton').click # dropdownmenu を探してクリック
          click_link 'ログアウト'  # click_button ×
          sign_in(user_b)
          visit users_article_path(article_a)
          expect(page).to_not have_content '編集'
          expect(page).to_not have_content '削除'
          expect(page).to have_content '投稿者'
          expect(page).to have_content article_a.user.name
        end
      end

      after do
        expect(current_path).to eq users_article_path(article)
        expect(page).to have_content article_a.title
        expect(page).to have_content article_a.sub_title
        expect(page).to have_content article_a.content
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
      expect(current_path).to eq users_article_path(Article.last)
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
      visit edit_users_article_path(article_a)
      prev_article_title = article_a.title
      fill_in 'article[title]', with: 'たいとる'
      fill_in 'article[sub_title]', with: 'さぶたいとる'
      fill_in 'article[content]', with: 'こんてんつ'
      click_button '更新'
      article.reload
      expect(current_path).to eq users_article_path(article)
      expect(page).to have_content '記事を編集しました。'
      expect(page).to have_content article_a.title
      #binding.pry
      expect(page).to_not have_content prev_article_title
    end

    it 'failure' do
      visit edit_users_article_path(article_a)
      fill_in 'article[title]', with: nil
      click_button '更新'
      expect(page).to have_content '記事の編集に失敗しました。'
      expect(page).to_not have_content article_a.title
    end
  end

  describe 'delete article' do
    context 'dashboards to delete' do
      it 'success' do
        #binding.pry
        visit users_dash_boards_path
        expect(page).to have_content article_a.title
        # page.find('.link-tr', text: article.title).click
        page.first('.link-td', text: article_a.title).click
        expect(current_path).to eq users_article_path(article_a)
        page.accept_confirm('表示中の記事を削除します。') do
          click_link "削除"
        end
        expect(page).to have_content '記事を削除しました。'
        expect(current_path).to eq users_dash_boards_path(user_a)
        expect(page).to_not have_content article_a.title
      end
    end

    context 'index to delete' do
      it 'success' do
        visit users_articles_path
        expect(page).to have_content article_a.title
        page.first('.link-td', text: article_a.title).click
        expect(current_path).to eq users_article_path(article)
        page.accept_confirm('表示中の記事を削除します。') do
          click_link "削除"
        end
        expect(page).to have_content '記事を削除しました。'
        expect(current_path).to eq users_articles_path
        expect(page).to_not have_content article_a.title
      end
    end
  end
  
  describe 'markdown with marked.js', js: true do # Marked.js によるマークダウン
    before do
      article_a.content = "# This is h1.  \r\n```ruby:qiita.rb\r\nputs 'The best way to log and share programmers knowledge.'\r\n```"
      article_a.save
    end
    
    describe 'new article page' do # 記事投稿画面で
      before do
        visit new_users_article_path
        sleep 1
        @markd = find('.markdown-editor')
        @preview = find('.preview')
      end
      
      it 'markdown to preview' do # プレビュー画面でマークダウンが機能している
        @markd.set(article_a.content)
        expect(@preview).to have_css('h1', text: 'This is h1.', wait: 1) # 「#」の文字列が、h1のcssになっていることを期待
      end
      
      it 'drag and drop image' do
        img = file_fixture("ruby.png")
        @markd.drop(img)
        page.save_screenshot 'rubyロゴ画像添付.png'
        expect(@preview).to have_css('img[alt="ruby.png"]', wait: 1)
        expect(@markd.value).to start_with '<img alt="ruby.png"'
      end
      
      it 'to code block' do
        @markd.set(article_a.content)
        page.save_screenshot 'newページのコードブロック.png'
        expect(@preview).to have_selector('.code-frame', visible: true)
        frame = @preview.find('.code-frame')
        expect(frame).to match_style({"background-color": "rgba(54, 69, 73, 1)"})
        expect(frame).to have_selector('.code-ref', visible: true)
        expect(frame).to have_css('.code-ref', text: "qiita.rb", visible: true)
        expect(frame).to have_css('code', text: "puts 'The best way to log and share programmers knowledge.'", visible: true)
      end
    end

    describe 'show article page' do
      it 'code copy' do
        visit users_article_path(article_a)
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
          expect(find('.copybtn').text).to_not eq 'コードコピー'
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
