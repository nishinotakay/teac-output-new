# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article, type: :model do
  # let(:user_a) { build(:user, :a, confirmed_at: Date.today) }
  let(:user) { create(:user, confirmed_at: Date.today) }
  let(:user_article) { create(:article, user: user) }
  # let(:user_article_yesterday) { create(:article, user: user, created_at: Date.today - 1.day) }
  let(:admin) { create(:admin, confirmed_at: Date.today) }
  let(:admin_article) { build(:article, admin: admin) }
  let(:user_articles) { create_list(:article, 10, user: user) }

  describe '条件検索について' do
    before(:each) do # 各itの前に１件の記事データを生成する
      user_article
    end

    context '条件を満たすデータが存在する場合' do
      it 'タイトルで一致する記事を返す' do
        filter = {
          title: 'タイトル',
          order: 'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(1) # 検索結果が1つを期待する
      end

      it 'サブタイトルで一致する記事を返す' do
        filter = {
          subtitle: 'サブタイトル',
          order:    'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '本文で一致する記事を返す' do
        filter = {
          content: '本文',
          order:   'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '投稿者で一致する記事を返す' do
        filter = {
          author: '山田太郎',
          order:  'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '指定日付範囲内の記事を返す' do
        filter = {
          start:  Date.current.to_s, # Date.today.to_s だと×
          finish: Date.current.to_s,
          order:  'ASC'
        }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '指定開始日以降の記事を返す' do
        filter = {
          start: Date.current.to_s,
          order: 'ASC'
        }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '指定終了日までの記事を返す' do
        filter = {
          finish: Date.current.to_s,
          order:  'ASC'
        }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '全ての条件を満たす記事を抽出できる' do
        user_articles # テストのため10件の記事を追加生成します
        filter = {
          start:    "#{Date.today.year}-01-01",
          finish:   "#{Date.today.year}-12-31",
          title:    'タイトル',
          subtitle: 'サブタイトル',
          content:  '本文',
          author:   '山田太郎',
          order:    'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(11)
        expect(articles).to match_array(Article.all) # articles == Article.all を期待する
      end
    end

    context '条件を満たすデータが存在しない場合' do
      it 'タイトルが一致せず空のリストを返す' do
        filter = {
          title: '存在しない',
          order: 'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles).to be_empty # be_falsy では×
      end

      it 'サブタイトルが一致せず空のリストを返す' do
        filter = {
          subtitle: '存在しない',
          order:    'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles).to be_empty
      end

      it '本文が一致せず空のリストを返す' do
        filter = {
          content: '存在しない',
          order:   'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles).to be_empty
      end

      it '投稿者が一致せず空のリストを返す' do
        filter = {
          author: '存在しない',
          order:  'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles).to be_empty
      end

      it '全ての条件を満たす記事が存在せず空のリストが返る' do
        filter = {
          start:    "#{Date.today.year}-01-01",
          finish:   "#{Date.today.year}-12-31",
          title:    '存在しない',
          subtitle: '存在しない',
          content:  '存在しない',
          author:   '存在しない',
          order:    'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles).to be_empty
      end
    end

    it '指定開始日からの記事が存在せず空のリストが返る' do
      user_article.update(created_at: Date.yesterday) # 記事の投稿日を前日に修正
      filter = {
        start: Date.current.to_s,
        order: 'ASC'
      }
      articles = Article.sort_filter(filter)
      expect(articles).to be_empty
    end

    it '指定終了日までの記事が存在せず空のリストが返る' do
      filter = {
        finish: Date.yesterday.to_s, # 終了日を前日に指定
        order:  'ASC'
      }
      articles = Article.sort_filter(filter)
      expect(articles).to be_empty
    end

    context '全てのフォームが未入力の場合' do
      it '全ての記事が抽出される' do
        user_articles # 複数記事抽出のため10件の記事を追加生成します
        filter = { title: '', sub_title: '', content: '', order: 'ASC' }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(11)
        expect(articles).to match_array(Article.all)
      end
    end
  end

  # chatGPT
  RSpec.shared_examples '記事投稿について' do
    it_behaves_like '正常な記事投稿について'
    it_behaves_like 'タイトルについて'
    it_behaves_like 'サブタイトルについて'
    it_behaves_like '本文について'
  end

  context 'ユーザーが記事を投稿する場合' do
    subject { user_article }

    it_behaves_like '記事投稿について'
  end

  context '管理者が記事を投稿する場合' do
    subject { admin_article }

    it_behaves_like '記事投稿について'
  end
end
