require 'rails_helper'

RSpec.describe 'Articles', type: :system do
  let(:user_a) { create(:user, :a, confirmed_at: Date.today) }
  let(:user_b) { create(:user, :b, confirmed_at: Date.today) }
  let(:article) { create(:article, user: user_a) }

  before do
    sign_in(user_a)
    article
  end

  describe 'redirect to #X' do
    context 'X = index || dashboards' do
      context 'index' do
        it 'success' do
          visit users_articles_path
          expect(current_path).to eq users_articles_path
          expect(page).to have_content '記事一覧'
          expect(page).to have_content '投稿者'
          expect(page).to have_content article.user.name, count: 2
        end
      end

      context 'dashboards' do
        it 'success' do
          visit users_dash_boards_path
          expect(current_path).to eq users_dash_boards_path
          expect(page).to have_content '投稿した記事一覧'
          expect(page).to_not have_content '投稿者'
          expect(page).to_not have_content article.user.name, count: 2
        end
      end

      after do
        expect(page).to have_content 'タイトル〜サブタイトル〜'
        expect(page).to have_content '投稿日'
        expect(page).to have_content article.created_at.strftime('%-m/%d %-H:%M')
        expect(page).to have_content article.title
        expect(page).to have_content article.sub_title
      end
    end

    context 'X = new || edit' do
      context 'new' do
        it 'success' do
          visit new_users_article_path
          expect(current_path).to eq new_users_article_path
          expect(page).to have_content "記事投稿"
          text = "タイトル 〜サブタイトル〜"
          expect(page).to have_content "コンテンツ"
        end
      end

      context 'edit' do
        it 'success' do
          visit edit_users_article_path(article)
          expect(current_path).to eq edit_users_article_path(article)
          expect(page).to have_content "記事編集"
          text = "#{article.title} 〜#{article.sub_title}〜"
          expect(page).to have_content article.content, count: 2
        end
      end

      after do
        expect(page).to have_content "新規記事"
        # expect(page).to have_content "エディター"
        expect(page).to have_content "プレビュー"
        expect(page).to have_content text
      end
    end

    context 'X = show' do
      context 'writer' do
        it 'success' do
          visit users_article_path(article)
          expect(page).to have_content '編集'
          expect(page).to have_content '削除'
          expect(page).to_not have_content article.user.name, count: 2
        end
      end

      context 'non_writer' do
        it 'success' do
          click_link 'ログアウト'
          sign_in(user_b)
          visit users_article_path(article)
          expect(page).to_not have_content '編集'
          expect(page).to_not have_content '削除'
          expect(page).to have_content '投稿者'
          expect(page).to have_content article.user.name
        end
      end

      after do
        expect(current_path).to eq users_article_path(article)
        expect(page).to have_content article.title
        expect(page).to have_content article.sub_title
        expect(page).to have_content article.content
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
      # expect(page).to have_content '記事を投稿しました。'
    end

    it 'failure' do
      visit new_users_article_path
      click_button '投稿'
      expect(page).to have_content '記事の作成に失敗しました。'
      # expect(page).to have_content '記事の投稿に失敗しました。'
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
      expect(current_path).to eq users_article_path(article)
      expect(page).to have_content '記事を編集しました。'
      expect(page).to have_content article.title
      expect(page).to_not have_content prev_article_title
    end

    it 'failure' do
      visit edit_users_article_path(article)
      fill_in 'article[title]', with: nil
      click_button '更新'
      expect(page).to have_content '記事の編集に失敗しました。'
      expect(page).to_not have_content article.title
    end
  end

  describe 'delete article' do
    context 'dashboards to delete' do
      it 'success' do
        visit users_dash_boards_path
        expect(page).to have_content article.title
        page.find('.link-tr', text: article.title).click
        expect(current_path).to eq users_article_path(article)
        page.accept_confirm('表示中の記事を削除します。') do
          click_link "削除"
        end
        expect(page).to have_content '記事を削除しました。'
        expect(current_path).to eq users_dash_boards_path(user_a)
        expect(page).to_not have_content article.title
      end
    end

    context 'index to delete' do
      it 'success' do
        visit users_articles_path
        expect(page).to have_content article.title
        page.find('.link-tr', text: article.title).click
        expect(current_path).to eq users_article_path(article)
        page.accept_confirm('表示中の記事を削除します。') do
          click_link "削除"
        end
        expect(page).to have_content '記事を削除しました。'
        expect(current_path).to eq users_articles_path
        expect(page).to_not have_content article.title
      end
    end
  end

  describe 'upload image' do
    it 'success', js: true do
      # png = fixture_file_upload("spec/fixtures/ruby.png", 'image/png')
      # png = File.new("spec/fixtures/ruby.png")
      png = file_fixture("ruby.png")

      # assert_equal 2, png 

      visit new_users_article_path

      source = page.find('.markdown-editor')
      source.click

      # source.drop(png)

      # page.execute_script <<-JS
      #   dataTransfer = new DataTransfer()
      #   dataTransfer.files.add(fakeFileInput.get(0).files[0])
      #   testEvent = new DragEvent('drop', {bubbles:true, dataTransfer: dataTransfer })
      #   $('.markdown-editor').dispatchEvent(testEvent)
      # JS      

      # var dragSource = document.querySelector('#item_#{item2_list1.id}');
      # var dropTarget = document.querySelector('#item_#{item1_list2.id}');

      page.execute_script <<-EOS
        var dragSource = $('.article-img');
        var dropTarget = $('.markdown-editor');
        window.dragMock.dragStart(dragSource).delay(100).dragOver(dropTarget).delay(100).drop(dropTarget);
      EOS
      puts page.driver.browser.manage.logs.get(:browser)
      # puts page.driver.browser.manage.logs.get(:browser).collect(&:message)

      # dragMock.dragStart(dragSource).drop(dropTarget);      
      # dragMock.dragStart('#{png}').delay(100).dragOver(dropTarget).delay(100).drop('#{source}');      
      # windows.dragMock.dragStart("#{png}").delay(100).dragOver("#{source}").delay(100).drop("#{source}");
      # window.dragMock.dragStart(dragSource).delay(100).dragOver(dropTarget).delay(100).drop(dropTarget);

      puts '0'
      # drop_file png, 'markdown-editor'
      puts '1'

      page.save_screenshot 'ruby画像添付.png'
    end
  end
end

# page.save_screenshot '記事投稿.png'
