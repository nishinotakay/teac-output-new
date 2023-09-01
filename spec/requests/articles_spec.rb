require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  let(:user_1) { build(:user, :a, confirmed_at: Date.today) }
  let(:user_2) { build(:user, :b, confirmed_at: Date.today) }
  let(:article) { create(:article, user: user_1) }

  describe 'GET /index' do
    article_count = 2
    let(:articles_1) { create_list(:article, article_count, user: user_1) }
    let(:articles_2) { create_list(:article, article_count, user: user_2) }

    before { articles_1 }

    context 'ログインユーザーが投稿者である場合' do
      it '記事一覧画面へ遷移する' do
        articles_2
        sign_in user_1
        get users_articles_url # 記事一覧画面へ遷移
        expect(response.status).to eq 200
        expect(response.body).to include user_1.name
        expect(response.body).to include user_2.name
        articles_1.concat(articles_2).each do |a|
          expect(response.body).to include a.title
          expect(response.body).to include a.sub_title
          expect(response.body).to include '編集'
          expect(response.body).to include '削除'
        end
      end
    end

    context 'ログインユーザーが投稿者でない場合' do
      it '記事一覧画面へ遷移する' do
        sign_in user_2 # ユーザー２でログイン
        get users_articles_url
        expect(response.status).to eq 200
        expect(response.body).to include user_1.name
        expect(response.body).to include user_2.name
        articles_1.each do |a|
          expect(response.body).to include a.title
          expect(response.body).to include a.sub_title
          expect(response.body).to_not include '編集'
          expect(response.body).to_not include '削除'
        end
      end
    end

    context 'ログインしていない場合' do
      it '記事一覧画面へ遷移せず、ログインページにリダイレクトする' do
        sign_out user_2
        get users_articles_url
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'GET /show' do
    context 'ログインユーザーが投稿者である場合' do
      it '記事詳細画面へ遷移する' do
        sign_in user_1
        get users_article_url(article) # ユーザー１投稿の記事詳細画面へ
        expect(response.status).to eq 200
        expect(response.body).to include '編集'
        expect(response.body).to include '削除'
        expect(response.body).to include article.title
        expect(response.body).to include article.sub_title
        expect(response.body).to include article.content
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do
      it '記事詳細画面へ遷移し、編集・削除ボタンが表示されない' do
        sign_in user_2
        get users_article_url(article) # ユーザー１が投稿した記事詳細画面へ
        expect(response.status).to eq 200
        expect(response.body).to_not include '編集'
        expect(response.body).to_not include '削除'
        expect(response.body).to include article.title
        expect(response.body).to include article.sub_title
        expect(response.body).to include article.content
      end
    end

    context 'ログインしていない場合' do
      it '記事詳細画面へ遷移せず、ログインページにリダイレクトする' do
        get users_article_url(article)
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'GET /new' do
    context 'ログインしている場合' do
      it '記事投稿画面へ遷移する' do
        sign_in user_1
        get new_users_article_url
        expect(response.status).to eq 200
      end
    end

    context 'ログインしていない場合' do
      it '記事投稿画面へ遷移せず、ログインページにリダイレクトする' do
        get new_users_article_url
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'GET /edit' do
    context 'ログインユーザーが投稿者である場合' do
      it '記事編集画面へ遷移する' do
        sign_in user_1
        get edit_users_article_url(article)
        expect(response.status).to eq 200
        expect(response.body).to include '<input', 'title-form', article.title, '/>'
        expect(response.body).to include '<input', 'subtitle-form', article.sub_title, '/>'
        expect(response.body).to include '<textarea', 'markdown-editor', '>', article.content, '</textarea>'
        expect(response.body).to include 'markdown-editor', article.content, '</div>'
        expect(response.body).to include 'preview-side', article.content, '</div>'
      end
    end

    context 'ログインユーザーが投稿者でない場合' do
      it '記事編集画面へ遷移せず、記事一覧画面へリダイレクトする' do
        sign_in user_2
        get edit_users_article_url(article)
        expect(response.status).to eq 302
        expect(response).to redirect_to users_articles_url
        expect(flash[:danger]).to eq '不正な操作です。'
      end
    end

    context 'ログインしていない場合' do
      it '記事編集画面へ遷移せず、ログインページにリダイレクトする' do
        get edit_users_article_url(article)
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'POST /create' do
    let(:params) { { article: attributes_for(:article, user_id: user_1.id) } }

    before { sign_in user_1 }

    context '記事投稿が成功した場合' do
      it '記事が保存され、記事詳細画面へ遷移する' do
        #binding.pry
        expect{ post users_articles_url params: params }.to change(Article, :count).by(1)
        expect(response.status).to eq 302
        expect(flash[:notice]).to eq '記事を作成しました。'
        expect(response).to redirect_to users_article_url(Article.last, dashboard: false)
      end
    end

    context '記事投稿が失敗した場合' do
      it '記事は作成されず、記事投稿画面へ遷移する' do
        params[:article][:title] = nil
        expect{ post users_articles_url params: params }.to change(Article, :count).by(0)
        expect(response.status).to eq 200
        expect(flash[:alert]).to eq '記事の作成に失敗しました。'
      end
    end

    context 'ログインしていない場合' do
      it '記事は作成されず、トップページへリダイレクトする' do
        sign_out user_1
        post users_articles_url params: params
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'PATCH /update' do
    let(:article) { create(:article, user: user_1) }

    before do
      sign_in user_1
      article
    end

    context 'ログインユーザーが投稿者であり' do
      context '編集内容が適切な場合' do
        it '記事を編集できる' do
          params = { article: { title: 'a', sub_title: 'b', content: 'c' } }
          patch users_article_url(article, params: params)
          article.reload
          expect(response.status).to eq 302
          expect(flash[:notice]).to eq '記事を編集しました。'
          expect(response).to redirect_to users_article_url(Article.last, dashboard: false)
        end
      end

      context '編集内容が不適切な場合' do
        it '記事を編集できない' do
          params = { article: { title: nil, sub_title: 'b', content: 'c' } }
          patch users_article_url(article, params: params)
          article.reload
          expect(flash[:alert]).to eq '記事の編集に失敗しました。'
        end
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do
      it '記事は更新されず、記事一覧画面へリダイレクトする' do
        sign_in user_2
        params = { article: { title: 'a', sub_title: 'b', content: 'c' } }
        patch users_article_url(article, params: params) # user_1の投稿記事を編集する
        article.reload
        expect(response.status).to eq 302
        expect(response).to redirect_to users_articles_url
        expect(flash[:danger]).to eq '不正な操作です。'
      end
    end

    context 'ログインしていない場合' do
      it '記事は更新されず、トップページへリダイレクトする' do
        sign_out user_1
        params = { article: { title: 'a', sub_title: 'b', content: 'c' } }
        patch users_article_url(article, params: params)
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:article) { create(:article, user: user_1) }

    before do
      sign_in user_1
      article
    end

    context 'ログインユーザーが投稿者である場合' do
      it '記事の削除ができ、投稿した記事一覧画面へ遷移する' do # dashboard: true
        expect{ delete users_article_url(article, dashboard: true) }.to change(Article, :count).by(-1)
        expect(response.status).to eq 302
        expect(flash[:notice]).to eq '記事を削除しました。'
        expect(response).to redirect_to users_dash_boards_url(user_1)
      end

      it '記事の削除ができ、記事一覧画面へ遷移する' do # dashboard: false
        expect{ delete users_article_url(article, dashboard: false) }.to change(Article, :count).by(-1)
        expect(response.status).to eq 302
        expect(flash[:notice]).to eq '記事を削除しました。'
        expect(response).to redirect_to users_articles_url
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do
      it '削除されず、記事一覧画面へリダイレクトする' do
        sign_in user_2
        expect{ delete users_article_url(article) }.not_to change(Article, :count) # 記事の数は変化しない
        expect(response.status).to eq 302
        expect(response).to redirect_to users_articles_url
        expect(flash[:danger]).to eq '不正な操作です。'
      end
    end

    context 'ログインしていない場合' do
      it '記事は削除されず、トップページへリダイレクトする' do
        sign_out user_1
        expect{ delete users_article_url(article) }.not_to change(Article, :count)
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'POST /image' do
    context 'ログインユーザーが投稿者である場合' do # 記事の生成前、データベース保存前の画像ドロップアンドドロップ作業
      it '記事に画像を添付できる' do
        user_1.save
        image = fixture_file_upload("spec/fixtures/files/ruby.png", 'image/png')
        sign_in user_1
        #binding.pry
        post users_articles_image_url, params: {image: image, user_id: user_1.id}
        expect(JSON.parse(response.body)['name']).to eq "ruby.png"
        expect(JSON.parse(response.body)['url']).to include "ruby.png"
        expect(JSON.parse(response.body)['url']).to include "/uploads/tmp/"
        uploaded_image_url = JSON.parse(response.body)['url']
        article_params = { title:'a', sub_title:'a', content: "<img src=\"#{uploaded_image_url}\">", user: user_1.id } # ここから画像投稿までのテストをする
        post users_articles_url, params: { article: article_params }
        expect(response.status).to eq 302
        expect(flash[:notice]).to eq '記事を作成しました。'
        expect(response).to redirect_to users_article_url(Article.last, dashboard: false)
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do # 悪意あるユーザーが、他ユーザーの投稿で画像添付できないテスト
      it '記事に画像を添付できない' do
        user_1.save
        image = fixture_file_upload("spec/fixtures/files/ruby.png", 'image/png')
        sign_in user_2
        post users_articles_image_url, params: {image: image, user_id: user_1.id}
        expect(response.status).to eq 401 # 401はUnauthorizedのステータスコードです
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq '画像の挿入に失敗しました。'
      end
    end

    context 'ログインしていない場合' do
      it '記事の画像は保存されず、トップページへリダイレクトする' do
        sign_out user_1
        image = fixture_file_upload("spec/fixtures/files/ruby.png", 'image/png')
        post users_articles_image_url, params: {image: image, user_id: user_1.id}
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
        expect(Article.last).to be_blank
      end
    end
  end

end
