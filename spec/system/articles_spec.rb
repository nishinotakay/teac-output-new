require 'rails_helper'

RSpec.describe 'Articles', type: :system do
  let(:user_a) { create(:user, :a, confirmed_at: Date.today) }
  let(:user_b) { create(:user, :b, confirmed_at: Date.today) }
  let(:article) { create(:article, user: user_a) }

  before(:each) do
    sign_in(user_a)
    article
  end

  describe 'redirect to #X' do
    context 'X = index || dashboards' do
      after(:each) do
        expect(page).to have_content 'タイトル'
        expect(page).to have_content 'サブタイトル'
        expect(page).to have_content '投稿日'
        expect(page).to have_content article.created_at.strftime('%-m/%d %-H:%M')
        expect(page).to have_content article.title
        expect(page).to have_content article.sub_title
      end

      context 'index' do
        it 'success' do
          visit users_articles_path
          expect(page).to have_current_path users_articles_path, ignore_query: true
          expect(page).to have_content '記事一覧'
          expect(page).to have_content '投稿者'
          expect(page).to have_content article.user.name
        end
      end

      context 'dashboards' do
        it 'success' do
          visit users_dash_boards_path
          expect(page).to have_current_path users_dash_boards_path, ignore_query: true
          expect(page).to have_content '投稿した記事一覧'
          expect(page).not_to have_content '投稿者'
          expect(page).not_to have_content article.user.name, count: 2
        end
      end
    end

    context 'X = new || edit' do
      after(:each) do
        expect(page).to have_content 'エディター'
        expect(page).to have_content 'プレビュー'
      end

      context 'new' do
        it 'success' do
          visit new_users_article_path
          expect(page).to have_current_path new_users_article_path, ignore_query: true
          expect(page).to have_content '記事投稿'
          expect(page).to have_css('.markdown-editor', placeholder: '本文')
        end
      end

      context 'edit' do
        it 'success' do
          visit edit_users_article_path(article)
          expect(page).to have_current_path edit_users_article_path(article), ignore_query: true
          expect(page).to have_content '記事編集'
          expect(page).to have_content article.content, count: 2
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
          # click_link 'ログアウト'
          find('ログアウト').click
          sign_in(user_b)
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
        page.find('.link-tr', text: article.title).click
        expect(page).to have_current_path users_article_path(article), ignore_query: true
        page.accept_confirm('表示中の記事を削除します。') do
          click_link '削除'
        end
        expect(page).to have_content '記事を削除しました。'
        expect(page).to have_current_path users_dash_boards_path(user_a), ignore_query: true
        expect(page).not_to have_content article.title
      end
    end

    context 'index to delete' do
      it 'success' do
        visit users_articles_path
        expect(page).to have_content article.title
        page.find('.link-tr', text: article.title).click
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

  describe 'markdown with marked.js', js: true do
    before(:each) do
      article.content = "# This is h1.  \r\n```ruby:qiita.rb\r\nputs 'The best way to log and share programmers knowledge.'\r\n```"
      article.save
    end

    describe 'new article page' do
      before(:each) do
        visit new_users_article_path
        sleep 1
        @markd = find('.markdown-editor')
        @preview = find('.preview')
      end

      it 'markdown to preview' do
        @markd.set(article.content)
        expect(@preview).to have_css('h1', text: 'This is h1.', wait: 1)
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
