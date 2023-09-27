require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  let(:user_a) { build(:user, :a, confirmed_at: Date.today) }
  let(:user_b) { build(:user, :b, confirmed_at: Date.today) }
  let(:article) { create(:article, user: user_a) }

  article_count = 2
  let(:articles_a) { create_list(:article, article_count, user: user_a) }
  let(:articles_b) { create_list(:article, article_count, user: user_b) }

  describe 'GET /index' do
    before(:each) { articles_a }

    context 'ログインユーザーが投稿者である場合' do
      it '記事一覧画面へ遷移する' do
        sign_in user_a
        articles_b
        get users_articles_url
        expect(response.status).to eq 200
        expect(response.body).to include user_a.name
        expect(response.body).to include user_b.name
        expect(response.body).to include user_a.articles.first.title
        expect(response.body).to include user_a.articles.last.title
        expect(response.body).to include user_b.articles.first.title
        expect(response.body).to include user_b.articles.last.title
      end
    end

    context 'ログインユーザーが投稿者でない場合' do
      it '記事一覧画面へ遷移する' do
        sign_in user_b
        get users_articles_url
        expect(response.status).to eq 200
        expect(response.body).to include user_a.name
        expect(response.body).to include user_a.articles.first.title
        expect(response.body).to include user_a.articles.last.title
      end
    end

    context 'ログインしていない場合' do
      it '記事一覧画面へ遷移せず、ログイン画面へリダイレクトする' do
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
        sign_in user_a
        get users_article_url(article)
        expect(response.status).to eq 200
        expect(response.body).to include user_a.name
        expect(response.body).to include article.title
        expect(response.body).to include article.sub_title
        expect(response.body).to include article.content
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do
      it '記事詳細画面へ遷移する' do
        sign_in user_b
        get users_article_url(article)
        expect(response.status).to eq 200
        expect(response.body).to include user_a.name
        expect(response.body).to include article.title
        expect(response.body).to include article.sub_title
        expect(response.body).to include article.content
      end
    end

    context 'ログインしていない場合' do
      it '記事詳細画面へ遷移せず、ログイン画面へリダイレクトする' do
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
        sign_in user_a
        get new_users_article_url
        expect(response.status).to eq 200
        expect(response.body).to include 'input', 'title-form', 'subtitle-form', 'textarea', 'markdown-editor', 'preview-side'
      end
    end

    context 'ログインしていない場合' do
      it '記事投稿画面へ遷移せず、ログイン画面へリダイレクトする' do
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
        sign_in user_a
        get edit_users_article_url(article)
        expect(response.status).to eq 200
        expect(response.body).to include article.title, article.sub_title, article.content
        expect(response.body).to include 'input', 'title-form', 'subtitle-form', 'textarea', 'markdown-editor', 'preview-side'
      end
    end

    context 'ログインユーザーが投稿者でない場合' do
      it '記事編集画面へ遷移せず、記事一覧画面へリダイレクトする' do
        sign_in user_b
        get edit_users_article_url(article)
        expect(response.status).to eq 302
        expect(response).to redirect_to users_articles_url
        expect(flash[:danger]).to eq '不正な操作です。'
      end
    end

    context 'ログインしていない場合' do
      it '記事編集画面へ遷移せず、ログイン画面へリダイレクトする' do
        get edit_users_article_url(article)
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'POST /create' do
    let(:params) { { article: attributes_for(:article, user_id: user_a.id) } }

    before(:each) { sign_in user_a }

    context '記事投稿が成功した場合' do
      it '記事が保存され、記事詳細画面へ遷移する' do
        expect { post users_articles_url params: params }.to change(Article, :count).by(1)
        expect(response.status).to eq 302
        expect(flash[:notice]).to eq '記事を作成しました。'
        expect(response).to redirect_to users_article_url(user_a.articles.last, dashboard: false)
      end
    end

    context '記事投稿が失敗した場合' do
      it '記事は作成されず、記事投稿画面へ遷移する' do
        params[:article][:title] = nil
        expect { post users_articles_url params: params }.to change(Article, :count).by(0)
        expect(response.status).to eq 200
        expect(flash[:alert]).to eq '記事の作成に失敗しました。'
        expect(response.body).to include '記事投稿'
      end
    end

    context 'SQL文を入力した場合' do
      it '記事投稿が成功し、クエリが実行されないこと' do
        post users_articles_url, params: { article: { title: 'a', sub_title: 'b', content: 'c', user_id: user_a.id } }
        params[:article][:content] = 'DELETE FROM articles;'
        expect { post users_articles_url params: params }.to change(Article, :count).by(1)
        expect(Article.first.title).to eq 'a'
      end
    end

    context '正規表現を入力した場合' do
      it '記事投稿が成功し、正規表現が実行されないこと' do
        params[:article][:content] = '/[0-9]/'
        expect { post users_articles_url params: params }.to change(Article, :count).by(1)
        expect(response.status).to eq 302
        expect(Article.last.content).to eq('/[0-9]/')
      end
    end

    context 'ログインしていない場合' do
      it '記事は作成されず、ログイン画面へリダイレクトする' do
        sign_out user_a
        post users_articles_url params: params
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'PATCH /update' do
    let(:article) { create(:article, user: user_a) }

    before(:each) do
      sign_in user_a
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
        sign_in user_b
        params = { article: { title: 'a', sub_title: 'b', content: 'c' } }
        patch users_article_url(article, params: params)
        article.reload
        expect(response.status).to eq 302
        expect(response).to redirect_to users_articles_url
        expect(flash[:danger]).to eq '不正な操作です。'
      end
    end

    context 'ログインしていない場合' do
      it '記事は更新されず、ログイン画面へリダイレクトする' do
        sign_out user_a
        params = { article: { title: 'a', sub_title: 'b', content: 'c' } }
        patch users_article_url(article, params: params)
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:article) { create(:article, user: user_a) }

    before(:each) do
      sign_in user_a
      article
    end

    context 'ログインユーザーが投稿者である場合' do
      it '記事の削除ができ、投稿した記事一覧画面へ遷移する' do
        expect { delete users_article_url(article, dashboard: true) }.to change(Article, :count).by(-1)
        expect(response.status).to eq 302
        expect(flash[:notice]).to eq '記事を削除しました。'
        expect(response).to redirect_to users_dash_boards_url(user_a)
      end

      it '記事の削除ができ、記事一覧画面へ遷移する' do
        expect { delete users_article_url(article, dashboard: false) }.to change(Article, :count).by(-1)
        expect(response.status).to eq 302
        expect(flash[:notice]).to eq '記事を削除しました。'
        expect(response).to redirect_to users_articles_url
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do
      it '削除されず、記事一覧画面へリダイレクトする' do
        sign_in user_b
        expect { delete users_article_url(article) }.not_to change(Article, :count)
        expect(response.status).to eq 302
        expect(response).to redirect_to users_articles_url
        expect(flash[:danger]).to eq '不正な操作です。'
      end
    end

    context 'ログインしていない場合' do
      it '記事は削除されず、ログイン画面へリダイレクトする' do
        sign_out user_a
        expect { delete users_article_url(article) }.not_to change(Article, :count)
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
      end
    end
  end

  describe 'POST /image' do
    context 'ログインユーザーが投稿者である場合' do
      it '記事に画像を添付できる' do
        user_a.save
        image = fixture_file_upload('spec/fixtures/files/ruby.png', 'image/png')
        sign_in user_a
        post users_articles_image_url, params: { image: image, user_id: user_a.id }
        expect(JSON.parse(response.body)['name']).to eq 'ruby.png'
        expect(JSON.parse(response.body)['url']).to include 'ruby.png'
        expect(JSON.parse(response.body)['url']).to include '/uploads/tmp/'
        uploaded_image_url = JSON.parse(response.body)['url']
        article_params = { title: 'a', sub_title: 'a', content: "<img src=\"#{uploaded_image_url}\">", user: user_a.id }
        post users_articles_url, params: { article: article_params }
        expect(response.status).to eq 302
        expect(flash[:notice]).to eq '記事を作成しました。'
        expect(response).to redirect_to users_article_url(Article.last, dashboard: false)
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do
      it '記事に画像を添付できない' do
        user_a.save
        image = fixture_file_upload('spec/fixtures/files/ruby.png', 'image/png')
        sign_in user_b
        post users_articles_image_url, params: { image: image, user_id: user_a.id }
        expect(response.status).to eq 401
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq '画像の挿入に失敗しました。'
      end
    end

    context 'ログインしていない場合' do
      it '記事の画像は保存されず、ログイン画面へリダイレクトする' do
        sign_out user_a
        image = fixture_file_upload('spec/fixtures/files/ruby.png', 'image/png')
        post users_articles_image_url, params: { image: image, user_id: user_a.id }
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(flash[:alert]).to eq 'ログインもしくはアカウント登録してください。'
        expect(Article.last).to be_blank
      end
    end
  end
end
