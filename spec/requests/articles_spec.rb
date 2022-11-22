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

    context 'user is writer' do
      it 'success' do
        articles_2
        sign_in user_1
        get users_articles_url
        expect(response.status).to eq 200
        expect(response.body).to include '<td>' + user_1.name + '</td>'
        expect(response.body).to include '<td>' + user_2.name + '</td>'
        articles_1.concat(articles_2).each do |a|
          expect(response.body).to include a.title
          expect(response.body).to include a.sub_title
        end
      end
    end

    context 'user isnot writer' do
      it 'success' do
        sign_in user_2
        get users_articles_url
        expect(response.status).to eq 200
        expect(response.body).to include '<td>' + user_1.name + '</td>'
        expect(response.body).to_not include '<td>' + user_2.name + '</td>'
        articles_1.each do |a|
          expect(response.body).to include a.title
          expect(response.body).to include a.sub_title
        end
      end
    end
  end

  describe 'GET /show' do
    context 'user eq writer' do
      it 'success' do
        sign_in user_1
        get users_article_url(article)
        expect(response.status).to eq 200
        expect(response.body).to include '編集'
        expect(response.body).to include '削除'
        expect(response.body).to include article.title
        expect(response.body).to include article.sub_title
        expect(response.body).to include article.content
      end
    end

    context 'user not_eq writer' do
      it 'success' do
        sign_in user_2
        get users_article_url(article)
        expect(response.status).to eq 200
        expect(response.body).to_not include '編集'
        expect(response.body).to_not include '削除'
        expect(response.body).to include article.title
        expect(response.body).to include article.sub_title
        expect(response.body).to include article.content
      end
    end
  end

  describe 'GET /new' do
    it 'success' do
      sign_in user_1
      get new_users_article_url
      expect(response.status).to eq 200
    end
  end

  describe 'GET /edit' do
    it 'success' do
      sign_in user_1
      get edit_users_article_url(article)
      expect(response.status).to eq 200
      expect(response.body).to include '<input', 'title-form', article.title, '/>'
      expect(response.body).to include '<input', 'subtitle-form', article.sub_title, '/>'
      expect(response.body).to include '<textarea', 'markdown-editor', '>' + article.content, '</textarea>'
      expect(response.body).to include '<span class="preview-title">' + article.title + '</span>'
      expect(response.body).to include '<span class="preview-subtitle">' + article.sub_title + '</span>'
      expect(response.body).to include 'markdown-editor', article.content, '</div>'
      expect(response.body).to include 'preview-content', article.content, '</div>'
    end
  end

  describe 'POST /create' do
    let(:params) { { article: attributes_for(:article, user_id: user_1.id) } }

    before { sign_in user_1 }

    it 'success' do
      expect{
        post users_articles_url params: params
      }.to change(Article, :count).by(1)
      expect(response.status).to eq 302
      expect(flash[:notice]).to eq 'メモを作成しました。'
      expect(response).to redirect_to users_article_url(Article.count)
    end

    it 'failure' do
      params[:article][:title] = nil
      expect{
        post users_articles_url params: params
      }.to change(Article, :count).by(0)
      expect(flash[:alert]).to eq 'メモの作成に失敗しました。'
    end
  end

  describe 'PATCH /update' do
    let(:article) { create(:article, user: user_1) }

    before do
      sign_in user_1
      article
    end

    it 'success' do
      params = { article: { sub_title: 'b', content: 'c' } }
      patch users_article_url(article, params: params)
      article.reload
      expect(response.status).to eq 302
      expect(flash[:notice]).to eq 'メモを編集しました。'
      expect(response).to redirect_to users_article_url(article.id)
    end

    it 'failure' do
      params = { article: { title: nil, sub_title: 'b', content: 'c' } }
      patch users_article_url(article, params: params)
      article.reload
      expect(flash[:alert]).to eq 'メモの編集に失敗しました。'
    end
  end

  describe 'DELETE /destroy' do
    let(:article) { create(:article, user: user_1) }

    before do
      sign_in user_1
      article
    end

    it 'success(dash_board)' do
      expect{
        delete users_article_url(article, dashboard: true)
      }.to change(Article, :count).by(-1)
      expect(response.status).to eq 302
      expect(flash[:notice]).to eq 'メモを削除しました。'
      expect(response).to redirect_to users_dash_boards_url(user_1)
    end

    it 'success(articles/index)' do
      expect{
        delete users_article_url(article, dashboard: false)
      }.to change(Article, :count).by(-1)
      expect(response.status).to eq 302
      expect(flash[:notice]).to eq 'メモを削除しました。'
      expect(response).to redirect_to users_articles_url
    end
  end

  describe 'POST /image' do
    let(:user) { create(:user, :a, confirmed_at: Date.today) }

    it 'success' do
      file_path = File.join(Rails.root, 'spec/fixtures/ruby.png')
      image = ActionDispatch::Http::UploadedFile.new(
        filename: File.basename(file_path),
        type: 'image/png',
        tempfile: File.open(file_path)
      )
      sign_in user
      post users_articles_image_url(image: image, user_id: user)
      articles = Article.all
      binding.pry
      expect(JSON.parse(response.body)['name']).to eq article
    end
  end

  pending 'add some examples (or delete) #{__FILE__}'
end
