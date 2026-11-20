require 'rails_helper'

RSpec.describe 'カテゴリーへの記事紐付けAPI', type: :request do
  around do |example|
    Current.reset
    example.run
  ensure
    Current.reset
  end

  let!(:tenant) { create(:tenant) }
  let!(:other_tenant) { create(:tenant) }
  let!(:admin) { create(:admin, tenant: tenant) }
  let!(:user) { create(:user, tenant: tenant) }
  let!(:other_admin) { create(:admin, tenant: other_tenant) }
  let!(:course) { create(:course, tenant: tenant) }
  let!(:category) { create(:category, course: course, tenant: tenant) }
  let!(:article) { create(:article, admin: admin, tenant: tenant, article_type: 'normal') }
  let!(:second_article) { create(:article, admin: admin, tenant: tenant, article_type: 'normal') }
  let!(:foreign_article) { create(:article, admin: other_admin, tenant: other_tenant, article_type: 'normal') }
  let(:headers) { { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" } }
  let(:collection_path) { "/api/v1/admin/categories/#{category.id}/articles" }

  def response_json
    JSON.parse(response.body)
  end

  describe 'POST /api/v1/admin/categories/:category_id/articles' do
    it '複数の記事を一括で紐付けて201と更新後の一覧を返す' do
      expect {
        post collection_path, params: { articleIds: [second_article.id.to_s, article.id.to_s] },
          headers: headers, as: :json
      }.to change(ArticleCategory, :count).by(2)

      expect(response).to have_http_status(:created)
      expect(response_json['category']).to include('id' => category.id.to_s, 'name' => category.name)
      expect(response_json['linkedArticles'].map { |linked_article| linked_article['id'] }).to eq([
        article.id.to_s, second_article.id.to_s
      ])
      expect(response_json['availableArticles']).to eq([])
      expect(ArticleCategory.where(category_id: category.id).pluck(:article_id)).to contain_exactly(article.id, second_article.id)
      expect(Article.unscoped.count).to eq(3)
    end

    it '登録済みの組み合わせは422とerrorsを返し重複登録しない' do
      existing_link = ArticleCategory.create!(category: category, article: article)

      expect {
        post collection_path, params: { articleIds: [article.id.to_s] }, headers: headers, as: :json
      }.not_to change(ArticleCategory, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json['errors']).to be_an(Array)
      expect(response_json['errors']).not_to be_empty
      expect(existing_link.reload).to have_attributes(category_id: category.id, article_id: article.id)
    end

    it '新規IDの後に登録済みIDがある場合も全件ロールバックする' do
      existing_link = ArticleCategory.create!(category: category, article: article)

      expect {
        post collection_path, params: { articleIds: [second_article.id.to_s, article.id.to_s] },
          headers: headers, as: :json
      }.not_to change(ArticleCategory, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(ArticleCategory.exists?(category_id: category.id, article_id: second_article.id)).to eq(false)
      expect(existing_link.reload.article_id).to eq(article.id)
    end

    it '同じリクエスト内でIDが重複しても422で全件保存しない' do
      expect {
        post collection_path, params: { articleIds: [article.id.to_s, article.id.to_s] }, headers: headers, as: :json
      }.not_to change(ArticleCategory, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response_json['errors']).not_to be_empty
    end

    it '他カテゴリーで使用中の記事を複製せず共有できる' do
      another_course = create(:course, tenant: tenant)
      another_category = create(:category, course: another_course, tenant: tenant)
      existing_link = ArticleCategory.create!(category: another_category, article: article)

      expect {
        post collection_path, params: { articleIds: [article.id.to_s] }, headers: headers, as: :json
      }.not_to change(Article.unscoped, :count)

      expect(response).to have_http_status(:created)
      expect(ArticleCategory.where(article_id: article.id).pluck(:category_id)).to contain_exactly(category.id, another_category.id)
      expect(existing_link.reload.article_id).to eq(article.id)
    end

    [nil, [], '1', ['invalid'], [1]].each do |invalid_ids|
      it "articleIdsが#{invalid_ids.inspect}なら400で保存しない" do
        expect {
          post collection_path, params: { articleIds: invalid_ids }, headers: headers, as: :json
        }.not_to change(ArticleCategory, :count)

        expect(response).to have_http_status(:bad_request)
      end
    end

    it '他テナントのカテゴリーへの紐付けは404でDBを変更しない' do
      foreign_course = create(:course, tenant: other_tenant)
      foreign_category = create(:category, course: foreign_course, tenant: other_tenant)

      expect {
        post "/api/v1/admin/categories/#{foreign_category.id}/articles",
          params: { articleIds: [article.id.to_s] }, headers: headers, as: :json
      }.not_to change(ArticleCategory, :count)

      expect(response).to have_http_status(:not_found)
      expect(foreign_category.reload.course_id).to eq(foreign_course.id)
    end
  end

  describe 'DELETE /api/v1/admin/categories/:category_id/articles/:id' do
    let!(:target_link) { ArticleCategory.create!(category: category, article: article) }

    it '指定した中間レコードだけを削除し記事と別の紐付けを残す' do
      another_category = create(:category, course: course, tenant: tenant)
      remaining_link = ArticleCategory.create!(category: another_category, article: article)
      original_content = article.content

      expect {
        delete "#{collection_path}/#{article.id}", headers: headers
      }.to change(ArticleCategory, :count).by(-1)

      expect(response).to have_http_status(:no_content)
      expect(response.body).to eq('')
      expect(ArticleCategory.exists?(target_link.id)).to eq(false)
      expect(remaining_link.reload.article_id).to eq(article.id)
      expect(article.reload.content).to eq(original_content)
      expect(category.reload.course_id).to eq(course.id)
    end

    it '対象カテゴリーに紐付いていない記事なら404でDBを変更しない' do
      expect {
        delete "#{collection_path}/#{second_article.id}", headers: headers
      }.not_to change(ArticleCategory, :count)

      expect(response).to have_http_status(:not_found)
      expect(target_link.reload.article_id).to eq(article.id)
    end
  end

  describe '管理操作の認証' do
    let!(:existing_link) { ArticleCategory.create!(category: category, article: article) }

    { '未認証' => nil, '一般ユーザー' => 'user' }.each do |role_name, role|
      context role_name do
        let(:rejected_headers) do
          role ? { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: role)}" } : {}
        end

        it '追加を401で拒否し中間レコードを作成しない' do
          expect {
            post collection_path, params: { articleIds: [second_article.id.to_s] }, headers: rejected_headers, as: :json
          }.not_to change(ArticleCategory, :count)

          expect(response).to have_http_status(:unauthorized)
          expect(existing_link.reload.article_id).to eq(article.id)
        end

        it '解除を401で拒否し中間レコードを保持する' do
          expect {
            delete "#{collection_path}/#{article.id}", headers: rejected_headers
          }.not_to change(ArticleCategory, :count)

          expect(response).to have_http_status(:unauthorized)
          expect(existing_link.reload.article_id).to eq(article.id)
        end
      end
    end
  end
end
