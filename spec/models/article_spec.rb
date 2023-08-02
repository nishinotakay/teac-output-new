# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:user) { create(:user) }
  let(:user_article) { create(:article, user: user) }
  let(:admin) { create(:admin) }
  let(:admin_article) { create(:article, admin: admin) }
  let(:user_and_admin_articles) { [create(:article, user: user), create(:article, admin: admin)] }

  describe '条件検索について' do
    before(:each) do # 各itの前に１件の記事データを生成する
      user_article
    end

    context '条件を満たすデータが存在する場合' do
      it 'タイトルで部分一致する記事を返す' do
        filter = {
          title: 'タイトル',
          order: 'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles.count).to eq(1) # 検索結果が1つを期待する
      end

      it 'サブタイトルで部分一致する記事を返す' do
        filter = {
          subtitle: 'サブタイトル',
          order:    'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '本文で部分一致する記事を返す' do
        filter = {
          content: '本文',
          order:   'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '投稿者で部分一致する記事を返す' do
        filter = {
          author: '山田太郎',
          order:  'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '指定日付範囲内の記事を返す' do
        filter = {
          start:  Date.current.to_s, # Date.today.to_s だと×
          finish: Date.current.to_s,
          order:  'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '指定開始日以降の記事を返す' do # 終了日は指定なし
        filter = {
          start: Date.current.to_s,
          order: 'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '指定終了日までの記事を返す' do # 開始日は指定なし
        filter = {
          finish: Date.current.to_s,
          order:  'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '部分一致で全ての条件を満たす記事を抽出できる' do
        filter = {
          start:    "#{Date.today.year}-01-01",
          finish:   "#{Date.today.year}-12-31",
          title:    'タイトル',
          subtitle: 'サブタイトル',
          content:  '本文',
          author:   '山田太郎',
          order:    'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles.count).to eq(1)
      end
    end

    context '条件を満たすデータが存在しない場合' do
      it 'タイトルが一致せず空のリストを返す' do
        filter = {
          title: '存在しない',
          order: 'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles).to be_empty # be_falsy では×
      end

      it 'サブタイトルが一致せず空のリストを返す' do
        filter = {
          subtitle: '存在しない',
          order:    'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles).to be_empty
      end

      it '本文が一致せず空のリストを返す' do
        filter = {
          content: '存在しない',
          order:   'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles).to be_empty
      end

      it '投稿者が一致せず空のリストを返す' do
        filter = {
          author: '存在しない',
          order:  'desc'
        }
        articles = described_class.sort_filter(filter)
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
        articles = described_class.sort_filter(filter)
        expect(articles).to be_empty
      end
    end

    it '指定開始日からの記事が存在せず空のリストが返る' do
      user_article.update(created_at: Date.yesterday) # 記事を前日投稿に修正
      filter = {
        start: Date.current.to_s,
        order: 'desc'
      }
      articles = described_class.sort_filter(filter)
      expect(articles).to be_empty
    end

    it '指定終了日までの記事が存在せず空のリストが返る' do
      filter = {
        finish: Date.yesterday.to_s, # 終了日を前日に指定
        order:  'desc'
      }
      articles = described_class.sort_filter(filter)
      expect(articles).to be_empty
    end

    context '全てのフォームが未入力の場合' do
      it '全ての記事が抽出される' do
        filter = { title: '', sub_title: '', content: '', order: 'desc' }
        articles = described_class.sort_filter(filter)
        expect(articles).to match_array(described_class.all) # 全ての記事抽出を確認するためallで実装
      end
    end
  end

  describe '複数記事の条件検索' do
    before(:each) do
      user_and_admin_articles # ユーザーと管理者の投稿記事を生成　計２件
    end

    context '条件を満たすデータが存在する場合' do
      it '条件で部分一致する全ての記事を返す' do
        filter = {
          title: 'タイトル',
          order: 'desc'
        }
        articles = described_class.sort_filter(filter)
        expect(articles.count).to eq(2)
      end
    end
  end

  describe '並び替え機能について' do
    before(:each) do
      user_and_admin_articles
    end

    context '古い順を押下した場合' do
      it '昇順で記事を返す' do
        filter = { order: 'ASC' }
        articles = described_class.sort_filter(filter)
        ids = articles.map(&:id)
        expect(ids).to eq ids.sort
        expect(articles.map(&:created_at)).to eq articles.map(&:created_at).sort # map → pluckメソッドも使用可
      end
    end

    context '新しい順を押下した場合' do
      it '昇順で記事を返す' do
        filter = { order: 'DESC' }
        articles = described_class.sort_filter(filter)
        ids = articles.map(&:id)
        expect(ids).to eq ids.sort.reverse # id が昇順を期待
        expect(articles.map(&:created_at)).to eq articles.map(&:created_at).sort.reverse # created_at が昇順を期待
      end
    end
  end

  RSpec.shared_examples '記事投稿について' do # 各テストの内容は spec/support/concerns/common_module.rb へ
    it_behaves_like '正常な記事投稿について'
    it_behaves_like 'タイトルについて'
    it_behaves_like 'サブタイトルについて'
    it_behaves_like '本文について'
    it_behaves_like 'アソシエーションについて'
  end

  context 'ユーザーが記事を投稿する場合' do
    subject(:article) { user_article } # 可読性高めるため、subject を article へ変更 aritcle { user_article } だとエラー

    it_behaves_like '記事投稿について'
  end

  context '管理者が記事を投稿する場合' do
    subject(:article) { admin_article }

    it_behaves_like '記事投稿について'
  end

  describe 'sanitized_contentメソッドについて' do # 以下はDBとのやり取り不要のため build で実装
    let(:article) { build(:article, content: '<script>タグを</script><iframe>取り除く</iframe>') }

    context '本文にscriptタグとiframeタグが含まれている場合' do
      it '取り除かれること' do
        binding.pry
        expect(article.sanitized_content).not_to include(
          '<script>',
          '</script>',
          '<iframe>',
          '</iframe>'
        )
      end
    end
  end
end
