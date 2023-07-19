# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Article, type: :model do
  #let(:user_a) { build(:user, :a, confirmed_at: Date.today) }
  let(:user) { create(:user, confirmed_at: Date.today) }
  let(:user_article) { build(:article, user: user) }
  let(:admin) { create(:admin, confirmed_at: Date.today) }
  let(:admin_article) { build(:article, admin: admin) }
  #let(:user) { create(:user, confirmed_at: Date.today) }
  #let!(:user_articles) { create_list(:article, 10, user: user) }

  describe '条件検索について' do
    subject { user_articles }
    before do # before(:each) do
      # 10個の記事を作成します
      10.times { create(:article, user: user) } # FactoryBot省略可
    end

    context "正常系" do
      it '条件を満たす記事を抽出できる' do # 10番目に生成された記事を条件検索します。_10
        filter = {
          start:    '2023-01-01',
          finish:   '2023-12-31',
          title:    '_10',
          subtitle: '_10',
          content:  '_10',
          author:   '山田太郎',
          order:    'desc'
        }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(1)
      end

      it '指定した日付範囲で抽出できる' do
        filter = {
          start:  Date.current.to_s, # Date.today.to_s だと×
          finish: Date.current.to_s,
          order:  'ASC'
        }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(10)
          # 必要に応じて他の期待を設定します。例えば、特定の記事が結果に含まれていること、または含まれていないことなど
      end
    end

    context "異常系" do
      it '条件を満たすタイトルが存在しない場合は空のリストが返る' do
        filter = { title: '存在しないタイトル', order: 'ASC' }
        articles = Article.sort_filter(filter)
        expect(articles).to be_empty # be_falsy では×
      end
      #binding.pry
      it 'フォーム未入力の場合、全ての記事が抽出される' do
        filter = { title: '', sub_title: '', content: '', order: 'ASC' }
        articles = Article.sort_filter(filter)
        expect(articles.count).to eq(10)
      end
    end
  end

  # 西野さんから文字列ver
  shared_examples '投稿テスト' do |user_type|

    user_type_jp = {
    'user' => 'ユーザー',
    'admin' => '管理者'
    }

    context "#{user_type_jp[user_type]}が記事を投稿する場合" do

      subject { send("#{user_type}_article") }
      it_behaves_like '正常な記事投稿について'
      it_behaves_like 'タイトルについて'
      it_behaves_like 'サブタイトルについて'
      it_behaves_like '本文について'
    end
  end

  include_examples '投稿テスト', 'user'
  include_examples '投稿テスト', 'admin'
end
