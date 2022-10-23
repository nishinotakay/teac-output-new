require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  let(:user_1) { build(:user, :a, confirmed_at: Date.today) }
  let(:user_2) { build(:user, :b, confirmed_at: Date.today) }
  let(:article) { create(:article, user: user_1) }

  describe 'GET /index' do
    article_count = 2
    let(:articles_1) { create_list(:article, article_count, user: user_1) }
    let(:articles_2) { create_list(:article, article_count, user: user_2) }

    before do
      articles_1
    end

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

  # aggregate_failures "testing response" do
  # end

  pending 'add some examples (or delete) #{__FILE__}'
end
