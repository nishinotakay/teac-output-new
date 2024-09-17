require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  let(:user_1) { create(:user, :a, confirmed_at: '2020-01-01') }
  let(:user_2) { create(:user, :b, confirmed_at: '2020-01-01') }
  let(:article_1) { create(:article, user: user_1) }
  let(:articles_1) { create_list(:article, 2, user: user_1) }
  let(:articles_2) { create_list(:article, 2, user: user_2) }

  describe 'GET /index' do
    before(:each) { articles_1 }

    context 'ログインしている場合' do
      before(:each) do
        sign_in user_1
        articles_2
        get users_articles_url, as: :json
      end

      it '全ての記事を取得できる' do
        expect(response.status).to eq 200
        json_response = JSON.parse(response.body)
        articles_1.concat(articles_2).each do |a|
          expect(response.body).to include a.title
          expect(response.body).to include a.sub_title
          expect(response.body).to include a.content
        end
        expect(json_response.length).to eq Article.count
      end
    end

    context 'ログインしていない場合' do
      before(:each) do
        get users_articles_url
      end

      it 'ログイン画面へリダイレクトする' do
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
      end
    end
  end

  describe 'GET /show' do
    context 'ログインユーザーが投稿者である場合' do
      before(:each) do
        sign_in user_1
      end

      it '記事詳細画面で記事を取得できる' do
        get users_article_url(article_1), as: :json
        expect(response.status).to eq 200
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq article_1.title
        expect(json_response['sub_title']).to eq article_1.sub_title
        expect(json_response['content']).to eq article_1.content
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do
      before(:each) do
        sign_in user_2
        get users_article_url(article_1), as: :json
      end

      it '記事詳細画面で記事を取得できる' do
        expect(response.status).to eq 200
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq article_1.title
        expect(json_response['sub_title']).to eq article_1.sub_title
        expect(json_response['content']).to eq article_1.content
      end
    end

    context 'ログインしていない場合' do
      before(:each) do
        get users_article_url(article_1)
      end

      it 'ログイン画面へリダイレクトする' do
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
      end
    end
  end

  describe 'GET /new' do
    context 'ログインしている場合' do
      before(:each) do
        sign_in user_1
        get new_users_article_url
      end

      it '記事投稿画面へ遷移する' do
        expect(response.status).to eq 200
        expect(response.body).to include 'input', 'title-form', 'subtitle-form', 'textarea', 'markdown-editor', 'preview-side'
      end
    end

    context 'ログインしていない場合' do
      before(:each) do
        get new_users_article_url
      end

      it 'ログイン画面へリダイレクトする' do
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
      end
    end
  end

  describe 'GET /edit' do
    context 'ログインユーザーが投稿者である場合' do
      before(:each) do
        sign_in user_1
      end

      it '記事を取得できる' do
        get edit_users_article_url(article_1), as: :json
        expect(response.status).to eq 200
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq article_1.title
        expect(json_response['sub_title']).to eq article_1.sub_title
        expect(json_response['content']).to eq article_1.content
      end

      it '記事編集画面へ遷移する' do
        get edit_users_article_url(article_1)
        expect(response.status).to eq 200
        expect(response.body).to include article_1.title, article_1.sub_title, article_1.content
        expect(response.body).to include 'input', 'title-form', 'subtitle-form', 'textarea', 'markdown-editor', 'preview-side'
      end
    end

    context 'ログインユーザーが投稿者でない場合' do
      before(:each) do
        sign_in user_2
        get edit_users_article_url(article_1)
      end

      it '記事一覧画面へリダイレクトする' do
        expect(response.status).to eq 302
        expect(response).to redirect_to users_articles_url
      end
    end

    context 'ログインしていない場合' do
      before(:each) do
        get edit_users_article_url(article_1)
      end

      it 'ログイン画面へリダイレクトする' do
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
      end
    end
  end

  describe 'POST /create' do
    let(:params) { { article: attributes_for(:article, user_id: user_1.id) } }

    before(:each) { sign_in user_1 }

    context '記事投稿が成功した場合' do
      it '記事が保存される' do
        expect { post users_articles_url(params: params), as: :json }.to change(Article, :count).by(1)
        expect(response.status).to eq 201
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq Article.last.title
        expect(json_response['sub_title']).to eq Article.last.sub_title
        expect(json_response['content']).to eq Article.last.content
      end

      it '記事詳細画面へリダイレクトする' do # レスポンスがHTMLの場合でテスト
        expect { post users_articles_url(params: params) }.to change(Article, :count).by(1)
        expect(response.status).to eq 302
        expect(response).to redirect_to users_article_url(user_1.articles.last, dashboard: false)
      end
    end

    context '記事投稿が失敗した場合' do
      it '記事は作成されない' do
        params[:article][:title] = nil
        expect { post users_articles_url(params: params), as: :json }.to change(Article, :count).by(0)
        expect(response.status).to eq 422
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to include('を入力してください')
        expect(json_response['title']).to include('は1文字以上で入力してください')
      end
    end

    context 'SQL文を入力した場合' do
      it '記事投稿が成功し、クエリが実行されないこと' do
        post users_articles_url, params: { article: { title: 'a', sub_title: 'b', content: 'c', user_id: user_1.id } } # 1件目を生成
        first_article = Article.first
        params[:article][:content] = 'DELETE FROM articles;' # 2件目の記事生成で、本文に全ての記事を削除するsqlを記述
        post users_articles_url(params: params), as: :json
        expect(response.status).to eq 201
        json_response = JSON.parse(response.body)
        expect(json_response['title']).to eq Article.last.title
        expect(json_response['sub_title']).to eq Article.last.sub_title
        expect(json_response['content']).to eq Article.last.content
        expect(first_article.present?).to eq true # 1件目の記事が削除されていない
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
      before(:each) do
        sign_out user_1
        post users_articles_url params: params
      end

      it 'ログイン画面へリダイレクトする' do
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
      end
    end
  end

  describe 'PATCH /update' do
    let(:article) { create(:article, user: user_1) }

    before(:each) do
      sign_in user_1
      article
    end

    context 'ログインユーザーが投稿者である場合' do
      let(:params) { { article: { title: 'a', sub_title: 'b', content: 'c' } } }

      context '編集内容が適切な場合' do
        it '記事の編集が成功する' do
          patch users_article_url(article_1, params: params), as: :json
          expect(response.status).to eq 200
          json_response = JSON.parse(response.body)
          expect(json_response['title']).to eq 'a'
          expect(json_response['sub_title']).to eq 'b'
          expect(json_response['content']).to eq 'c'
        end

        it '記事詳細画面へリダイレクトする' do
          patch users_article_url(article_1, params: params)
          article_1.reload
          expect(response.status).to eq 302
          expect(response).to redirect_to users_article_url(article_1, dashboard: false)
        end
      end

      context '編集内容が不適切な場合' do
        before(:each) do
          params[:article][:title] = nil
          patch users_article_url(article_1, params: params), as: :json
        end

        it '記事の編集に失敗する' do
          expect(response.status).to eq 422
          json_response = JSON.parse(response.body)
          expect(json_response['title']).to include('を入力してください')
          expect(json_response['title']).to include('は1文字以上で入力してください')
          expect(article_1.title).not_to eq nil
        end
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do
      before(:each) do
        sign_in user_2
        params = { article: { title: 'a', sub_title: 'b', content: 'c' } }
        patch users_article_url(article, params: params)
        article_1.reload
      end

      it '記事一覧画面へリダイレクトする' do
        expect(response.status).to eq 302
        expect(article_1.title).not_to eq 'a'
        expect(article_1.sub_title).not_to eq 'b'
        expect(article_1.content).not_to eq 'c'
        expect(response).to redirect_to users_articles_url
      end
    end

    context 'ログインしていない場合' do
      before(:each) do
        sign_out user_1
        params = { article: { title: 'a', sub_title: 'b', content: 'c' } }
        patch users_article_url(article, params: params)
      end

      it 'ログイン画面へリダイレクトする' do
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
      end
    end
  end

  describe 'DELETE /destroy' do
    let(:article_1) { create(:article, user: user_1) }

    before(:each) do
      sign_in user_1
      article_1
    end

    context 'ログインユーザーが投稿者である場合' do
      context '投稿した記事一覧画面で削除を行った場合' do
        before(:each) do
          delete users_article_url(article_1, dashboard: true)
        end

        it '記事の削除ができる' do
          expect(Article.find_by(id: article_1.id)).to be_nil
          expect(response.status).to eq 302
        end

        it '投稿した記事一覧画面へ遷移する' do
          expect(response).to redirect_to users_dash_boards_url(user_1)
        end
      end

      context '記事一覧画面で削除を行った場合' do
        before(:each) do
          delete users_article_url(article_1, dashboard: false)
        end

        it '記事の削除ができる' do
          expect(Article.find_by(id: article_1.id)).to be_nil
          expect(response.status).to eq 302
        end

        it '記事一覧画面へ遷移する' do
          expect(response).to redirect_to users_articles_url
        end
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do
      before(:each) do
        sign_in user_2
        delete users_article_url(article_1)
      end

      it '記事は削除されない' do
        expect(Article.find_by(id: article_1.id)).to be_truthy
        expect(response.status).to eq 302
      end

      it '記事一覧画面へリダイレクトする' do
        expect(response).to redirect_to users_articles_url
      end
    end

    context 'ログインしていない場合' do
      before(:each) do
        sign_out user_1
      end

      it 'ログイン画面へリダイレクトする' do
        expect { delete users_article_url(article_1) }.not_to change(Article, :count)
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
      end
    end
  end

  describe 'POST /image' do
    context 'ログインユーザーが投稿者である場合' do
      before(:each) do
        user_1.save
        image = fixture_file_upload('spec/fixtures/files/ruby.png', 'image/png')
        sign_in user_1
        post users_articles_image_url, params: { image: image, user_id: user_1.id }
      end

      it '記事に画像を添付できる' do
        expect(JSON.parse(response.body)['name']).to eq 'ruby.png'
        expect(JSON.parse(response.body)['url']).to include 'ruby.png'
        expect(JSON.parse(response.body)['url']).to include '/uploads/tmp/'
        uploaded_image_url = JSON.parse(response.body)['url']
        article_params = { title: 'a', sub_title: 'a', content: "<img src=\"#{uploaded_image_url}\">", user: user_1.id }
        post users_articles_url, params: { article: article_params }
        expect(response.status).to eq 302
        expect(response).to redirect_to users_article_url(Article.last, dashboard: false)
      end
    end

    context 'ログインユーザーが投稿者ではない場合' do
      before(:each) do
        user_1.save
        image = fixture_file_upload('spec/fixtures/files/ruby.png', 'image/png')
        sign_in user_2
        post users_articles_image_url, params: { image: image, user_id: user_1.id }
      end

      it '記事に画像を添付できない' do
        expect(response.status).to eq 401
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq '画像の挿入に失敗しました。'
      end
    end

    context 'ログインしていない場合' do
      before(:each) do
        sign_out user_1
        image = fixture_file_upload('spec/fixtures/files/ruby.png', 'image/png')
        post users_articles_image_url, params: { image: image, user_id: user_1.id }
      end

      it 'ログイン画面へリダイレクトする' do
        expect(response.status).to eq 302
        expect(response).to redirect_to user_session_url
        expect(Article.last).to be_blank
      end
    end
  end
end
