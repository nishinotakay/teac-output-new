# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article, type: :model do
  let(:user) { create(:user) }
  let(:user_article) { create(:article, title: 'タイトル', sub_title: 'サブタイトル', content: 'コンテント', user: user) }
  let(:admin) { create(:admin) }
  let(:admin_article) { create(:article, title: 'タイトル', sub_title: 'サブタイトル', content: 'コンテント', admin: admin) }
  let(:many_articles) do
    35.times do |i|
      create(:article,
        title:      'タイトル',
        sub_title:  'サブタイトル',
        content:    'コンテント',
        created_at: "2022-01-#{i + 1}",
        user:       user)
    end
  end

  RSpec.shared_examples '記事投稿' do # 各テストの内容は spec/support/concerns/common_module.rb へ
    it_behaves_like '正常な記事投稿'
    it_behaves_like 'タイトル'
    it_behaves_like 'サブタイトル'
    it_behaves_like '本文'
    it_behaves_like 'アソシエーション'
  end

  context 'ユーザーが記事を投稿する場合' do
    subject(:article) { user_article } # 可読性高めるため、subject を article へ変更 aritcle { user_article } だとエラー

    it_behaves_like '記事投稿'
  end

  context '管理者が記事を投稿する場合' do
    subject(:article) { admin_article }

    it_behaves_like '記事投稿'
  end

  describe 'paginated_and_sort_filter' do
    describe '条件検索' do
      before(:each) do # 各itの前に１件の記事データを生成する
        user_article
      end

      context 'タイトルで検索をかけた場合' do
        it '完全一致する記事を返す' do
          filter = {
            title: 'タイトル',
            order: 'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.title).to eq 'タイトル'
        end

        it '前方一致する記事を返す' do
          filter = {
            title: 'タイ',
            order: 'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.title).to eq 'タイトル'
        end

        it '中央一致する記事を返す' do
          filter = {
            title: 'イト',
            order: 'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.title).to eq 'タイトル'
        end

        it '後方一致する記事を返す' do
          filter = {
            title: 'トル',
            order: 'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.title).to eq 'タイトル'
        end
      end

      context 'サブタイトルで検索をかけた場合' do
        it '完全一致する記事を返す' do
          filter = {
            subtitle: 'サブタイトル',
            order:    'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
        end

        it '前方一致する記事を返す' do
          filter = {
            subtitle: 'サブタ',
            order:    'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
        end

        it '中央一致する記事を返す' do
          filter = {
            subtitle: 'ブタイ',
            order:    'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
        end

        it '後方一致する記事を返す' do
          filter = {
            subtitle: 'イトル',
            order:    'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
        end
      end

      context '本文で検索をかけた場合' do
        it '完全一致する記事を返す' do
          filter = {
            content: 'コンテント',
            order:   'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.content).to eq 'コンテント'
        end

        it '前方一致する記事を返す' do
          filter = {
            content: 'コン',
            order:   'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.content).to eq 'コンテント'
        end

        it '中央一致する記事を返す' do
          filter = {
            content: 'ンテン',
            order:   'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.content).to eq 'コンテント'
        end

        it '後方一致する記事を返す' do
          filter = {
            content: 'ント',
            order:   'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.content).to eq 'コンテント'
        end
      end

      context '投稿者で検索をかけた場合' do
        it '完全一致する一致する記事を返す' do
          filter = {
            author: '山田太郎',
            order:  'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.user.name).to eq '山田太郎'
        end

        it '前方一致する一致する記事を返す' do
          filter = {
            author: '山田',
            order:  'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.user.name).to eq '山田太郎'
        end

        it '中央一致する一致する記事を返す' do
          filter = {
            author: '田太',
            order:  'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.user.name).to eq '山田太郎'
        end

        it '後方一致する一致する記事を返す' do
          filter = {
            author: '太郎',
            order:  'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
          expect(articles.first.user.name).to eq '山田太郎'
        end
      end

      context '日付範囲で検索をかけた場合' do
        it '指定日付範囲内の記事を返す' do
          filter = {
            start:  Date.current.to_s,
            finish: Date.current.to_s,
            order:  'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
        end

        context '指定日付範囲で記事が存在しない場合' do
          it '空のリストが返る' do
            filter = {
              start:  Date.yesterday.to_s,
              finish: Date.yesterday.to_s,
              order:  'desc'
            }
            articles = described_class.paginated_and_sort_filter(filter)
            expect(articles).to be_empty
          end
        end
      end

      context '指定開始日で検索をかけた場合' do
        it '指定開始日以降の記事を返す' do # 終了日は指定なし
          filter = {
            start: Date.current.to_s,
            order: 'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
        end

        context '指定開始日からの記事が存在しない場合' do
          it '空のリストが返る' do
            user_article.update(created_at: Date.yesterday) # 記事を前日投稿に修正
            filter = {
              start: Date.current.to_s,
              order: 'desc'
            }
            articles = described_class.paginated_and_sort_filter(filter)
            expect(articles).to be_empty
          end
        end
      end

      context '指定終了日で検索をかけた場合' do
        it '一致する記事を返す' do # 開始日は指定なし
          filter = {
            finish: Date.current.to_s,
            order:  'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
        end

        context '指定終了日までの記事が存在しない場合' do
          it '空のリストが返る' do
            filter = {
              finish: Date.yesterday.to_s, # 終了日を前日に指定
              order:  'desc'
            }
            articles = described_class.paginated_and_sort_filter(filter)
            expect(articles).to be_empty
          end
        end
      end

      context '複数の条件で検索をかけた場合' do
        it '全ての条件を満たす記事を抽出できる' do
          filter = {
            start:    "#{Date.today.year}-01-01",
            finish:   "#{Date.today.year}-12-31",
            title:    'タイトル',
            subtitle: 'サブタイトル',
            content:  'コンテント',
            author:   '山田太郎',
            order:    'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(1)
        end
      end

      context '全てのフォームが未入力の場合' do
        it '全ての記事が抽出される' do
          filter = { title: '', sub_title: '', content: '', order: 'desc' }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles).to match_array(described_class.all) # 全ての記事抽出を確認するためallで実装
        end
      end
    end

    describe '複数記事の条件検索' do
      before(:each) do
        user_article
        admin_article # ユーザーと管理者の投稿記事を生成　計２件
      end

      context '条件を満たすデータが存在する場合' do
        it '条件で部分一致する全ての記事を返す' do
          filter = {
            title: 'タイトル',
            order: 'desc'
          }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq(2)
        end
      end
    end

    describe '並び替え機能' do
      before(:each) do
        many_articles
      end

      context '古い順を押下した場合' do
        it '昇順で記事を返す' do
          filter = { order: 'ASC', page: 1 }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles).to eq articles.sort
        end
      end

      context '新しい順を押下した場合' do
        it '降順で記事を返す' do
          filter = { order: 'DESC', page: 1 }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles).to eq articles.sort.reverse # created_at が降順を期待
        end
      end
    end

    describe 'ページネーション機能' do
      before(:each) do
        many_articles
      end

      context '1ページ目' do
        it '30件の記事が新しい順で取得される' do
          filter = { order: 'DESC', page: 1 }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq 30
          expect(articles).to eq articles.sort.reverse
        end
      end

      context '２ページ目' do
        it '5件の記事が新しい順で取得される' do
          filter = { order: 'DESC', page: 2 }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles.count).to eq 5
          expect(articles).to eq articles.sort.reverse
        end
      end

      context '作成日がフィルタリングされた場合' do
        it '作成日が新しい順で記事が取得される' do
          filter = { order: 'DESC', page: 1, start: '2020-02-02' }
          articles = described_class.paginated_and_sort_filter(filter)
          expect(articles).to eq articles.sort.reverse
        end
      end

      context '並び替えを古い順で選択' do
        context '1ページ目' do
          it '30件の記事が古い順で取得される' do
            filter = { order: 'ASC', page: 1 }
            articles = described_class.paginated_and_sort_filter(filter)
            expect(articles.count).to eq 30
            expect(articles).to eq articles.sort
          end
        end

        context '２ページ目' do
          it '5件の記事が古い順で取得される' do
            filter = { order: 'ASC', page: 2 }
            articles = described_class.paginated_and_sort_filter(filter)
            expect(articles.count).to eq 5
            expect(articles).to eq articles.sort
          end
        end

        context '作成日がフィルタリングされた場合' do
          it '作成日が新しい順で記事が取得される' do
            filter = { order: 'DESC', page: 1, start: '2020-02-02' }
            articles = described_class.paginated_and_sort_filter(filter)
            expect(articles).to eq articles.sort.reverse
          end
        end
      end
    end
  end

  describe 'sanitized_contentメソッド' do # 以下はDBとのやり取り不要のため build で実装
    let(:article) { build(:article, content: '<script>タグを</script><iframe>取り除く</iframe>') }

    context '本文にscriptタグとiframeタグが含まれている場合' do
      it '取り除かれること' do
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
