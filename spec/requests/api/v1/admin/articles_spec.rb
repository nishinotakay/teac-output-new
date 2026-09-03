require 'rails_helper'

RSpec.describe 'Api::V1::Admin::Articles' do
  def admin_auth_headers(admin)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" }
  end

  def user_auth_headers(user)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" }
  end

  def returned_articles
    JSON.parse(response.body)['articles']
  end

  def returned_article_ids
    returned_articles.map { |article| article['id'] }
  end

  let(:current_admin) { create(:admin) }
  let(:admin_headers) { admin_auth_headers(current_admin) }

  describe 'GET /api/v1/admin/articles' do
    context '管理者として認証済みの場合' do
      let(:author_user) { create(:user, name: '山田花子') }
      let(:author_admin) { create(:admin, name: '佐藤講師') }
      let!(:user_article) do
        create(
          :article,
          user:       author_user,
          title:      'Rails検索入門',
          sub_title:  'Active Recordの基本',
          content:    '部分一致検索を学ぶ本文',
          # 23:30 JST: 終了日の終端判定に end_of_day が入っているかを検知する（TZ の検知は翌日 00:30 の陰性対照が担う）
          created_at: Time.zone.local(2026, 8, 10, 23, 30)
        )
      end
      let!(:admin_article) do
        create(
          :article,
          admin:        author_admin,
          # 管理者の記事は article_type が必須（Article のバリデーション）
          article_type: 'normal',
          title:        'React実践',
          sub_title:    '状態管理',
          content:      'コンポーネント設計の本文',
          # 00:30 JST: 開始日の始端判定がタイムゾーンを考慮しているかを検知する
          created_at:   Time.zone.local(2026, 8, 20, 0, 30)
        )
      end

      it '既存フィールドの名前と値を維持する' do
        get '/api/v1/admin/articles', headers: admin_headers

        expect(response).to have_http_status(:ok)
        returned_article = returned_articles.find do |article|
          article['id'] == user_article.id.to_s
        end

        expect(returned_article).to include(
          'id'          => user_article.id.to_s,
          'title'       => user_article.title,
          'subTitle'    => user_article.sub_title,
          'content'     => user_article.content,
          'articleType' => user_article.article_type,
          'userId'      => author_user.id.to_s,
          'adminId'     => nil,
          'createdAt'   => user_article.created_at.iso8601,
          'updatedAt'   => user_article.updated_at.iso8601
        )
        # image は CarrierWave のアップローダ経由のため、キーの存在だけを確認する
        expect(returned_article).to have_key('image')
      end

      it '受講生の記事に受講生名をauthorNameとして返す' do
        get '/api/v1/admin/articles', headers: admin_headers

        returned_article = returned_articles.find do |article|
          article['id'] == user_article.id.to_s
        end

        expect(returned_article['authorName']).to eq(author_user.name)
      end

      it '管理者の記事に管理者名を投稿者名として返す' do
        get '/api/v1/admin/articles', headers: admin_headers

        returned_article = returned_articles.find do |article|
          article['id'] == admin_article.id.to_s
        end

        expect(returned_article['authorName']).to eq(author_admin.name)
      end

      it 'パラメータ未指定時はサブタイトルがNULLの記事とe-learning記事も含めて全件返す' do
        null_subtitle_article = create(:article, user: author_user, sub_title: nil)
        e_learning_article = create(
          :article,
          admin:        author_admin,
          article_type: 'e-learning'
        )

        get '/api/v1/admin/articles', headers: admin_headers

        expect(returned_article_ids).to contain_exactly(
          user_article.id.to_s,
          admin_article.id.to_s,
          null_subtitle_article.id.to_s,
          e_learning_article.id.to_s
        )
      end

      it 'タイトルを部分一致で絞り込む' do
        get '/api/v1/admin/articles', params: { title: '検索入' }, headers: admin_headers

        expect(returned_article_ids).to eq([user_article.id.to_s])
      end

      it 'サブタイトルを部分一致で絞り込む' do
        get '/api/v1/admin/articles', params: { subtitle: '状態' }, headers: admin_headers

        expect(returned_article_ids).to eq([admin_article.id.to_s])
      end

      it '本文を部分一致で絞り込む' do
        get '/api/v1/admin/articles', params: { content: '部分一致' }, headers: admin_headers

        expect(returned_article_ids).to eq([user_article.id.to_s])
      end

      it '受講生名を部分一致で絞り込む' do
        get '/api/v1/admin/articles', params: { author: '田花' }, headers: admin_headers

        expect(returned_article_ids).to eq([user_article.id.to_s])
      end

      it '管理者名を部分一致で絞り込む' do
        get '/api/v1/admin/articles', params: { author: '藤講' }, headers: admin_headers

        expect(returned_article_ids).to eq([admin_article.id.to_s])
      end

      it '開始日の始端以降に絞り込む' do
        get '/api/v1/admin/articles', params: { start: '2026-08-20' }, headers: admin_headers

        expect(returned_article_ids).to eq([admin_article.id.to_s])
      end

      it '終了日の終端以前に絞り込む' do
        # 翌日 00:30 JST（= 当日 15:30 UTC）: 終端判定が UTC 基準に退行すると混入する陰性対照
        create(:article, user: author_user, created_at: Time.zone.local(2026, 8, 11, 0, 30))

        get '/api/v1/admin/articles', params: { finish: '2026-08-10' }, headers: admin_headers

        expect(returned_article_ids).to eq([user_article.id.to_s])
      end

      it '開始日と終了日を同時に指定して範囲内に絞り込む' do
        middle_article = create(
          :article,
          user:       author_user,
          created_at: Time.zone.local(2026, 8, 15, 12)
        )

        get '/api/v1/admin/articles',
          params:  { start: '2026-08-14', finish: '2026-08-16' },
          headers: admin_headers

        expect(returned_article_ids).to eq([middle_article.id.to_s])
      end

      it '複数の絞り込み条件と並び順を同時に適用する' do
        matching_article = create(
          :article,
          user:       author_user,
          title:      'Rails検索応用',
          sub_title:  'Active Record実践',
          content:    '部分一致検索の応用本文',
          created_at: Time.zone.local(2026, 8, 12, 12)
        )

        get '/api/v1/admin/articles',
          params:  {
            author:   '山田',
            title:    'Rails検索',
            subtitle: 'Active Record',
            content:  '部分一致検索',
            start:    '2026-08-01',
            finish:   '2026-08-31',
            order:    'ASC'
          },
          headers: admin_headers

        expect(returned_article_ids).to eq([
          user_article.id.to_s,
          matching_article.id.to_s
        ])
      end

      it 'orderがASCの場合は作成日時とIDの昇順で返す' do
        same_time_article = create(
          :article,
          user:       author_user,
          created_at: user_article.created_at
        )

        get '/api/v1/admin/articles', params: { order: 'ASC' }, headers: admin_headers

        expect(returned_article_ids).to eq([
          user_article.id.to_s,
          same_time_article.id.to_s,
          admin_article.id.to_s
        ])
      end

      it 'orderが小文字のascでも昇順で返す' do
        get '/api/v1/admin/articles', params: { order: 'asc' }, headers: admin_headers

        expect(returned_article_ids).to eq([
          user_article.id.to_s,
          admin_article.id.to_s
        ])
      end

      it 'orderが未指定の場合は作成日時とIDの降順で返す' do
        same_time_article = create(
          :article,
          user:       author_user,
          created_at: admin_article.created_at
        )

        get '/api/v1/admin/articles', headers: admin_headers

        expect(returned_article_ids).to eq([
          same_time_article.id.to_s,
          admin_article.id.to_s,
          user_article.id.to_s
        ])
      end

      it 'orderが不正な値の場合は作成日時とIDの降順で返す' do
        same_time_article = create(
          :article,
          user:       author_user,
          created_at: admin_article.created_at
        )

        get '/api/v1/admin/articles', params: { order: 'invalid' }, headers: admin_headers

        expect(returned_article_ids).to eq([
          same_time_article.id.to_s,
          admin_article.id.to_s,
          user_article.id.to_s
        ])
      end

      context '日付パラメータが不正な場合' do
        it 'startが日付として解釈できない文字列なら400を返す' do
          get '/api/v1/admin/articles', params: { start: 'abc' }, headers: admin_headers

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['error']).to eq('start は YYYY-MM-DD 形式で指定してください')
        end

        it 'finishが存在しない日付なら400を返す' do
          get '/api/v1/admin/articles', params: { finish: '2026-13-45' }, headers: admin_headers

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['error']).to eq('finish は YYYY-MM-DD 形式で指定してください')
        end

        it 'startが配列で渡されても400を返す' do
          get '/api/v1/admin/articles', params: { start: ['2026-08-01'] }, headers: admin_headers

          expect(response).to have_http_status(:bad_request)
        end

        it 'startが128文字を超える文字列でも400を返す' do
          # date gem は 128 文字超で Date::Error ではなく素の ArgumentError を投げる
          get '/api/v1/admin/articles', params: { start: 'a' * 129 }, headers: admin_headers

          expect(response).to have_http_status(:bad_request)
        end

        it 'startがハイフンなしのISO基本形式なら400を返す' do
          get '/api/v1/admin/articles', params: { start: '20260801' }, headers: admin_headers

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['error']).to eq('start は YYYY-MM-DD 形式で指定してください')
        end

        it 'finishがISO週日付形式なら400を返す' do
          get '/api/v1/admin/articles', params: { finish: '2026-W32-6' }, headers: admin_headers

          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['error']).to eq('finish は YYYY-MM-DD 形式で指定してください')
        end
      end
    end

    context '未認証の場合' do
      it '401を返す' do
        get '/api/v1/admin/articles'

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context '受講生として認証済みの場合' do
      it '401を返す' do
        user = create(:user)

        get '/api/v1/admin/articles', headers: user_auth_headers(user)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
