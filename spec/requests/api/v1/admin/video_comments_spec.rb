require 'rails_helper'

RSpec.describe 'Api::V1::Admin::VideoComments', type: :request do
  def admin_auth_headers(admin)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" }
  end

  def user_auth_headers(user)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" }
  end

  def json
    JSON.parse(response.body)
  end

  def comment_count
    VideoComment.unscoped.count
  end

  let(:tenant) { create(:tenant) }
  let(:other_tenant) { create(:tenant) }
  let(:current_admin) { create(:admin, tenant: tenant) }
  let(:other_admin) { create(:admin, tenant: tenant) }
  let(:student) { create(:user, tenant: tenant) }
  let(:headers) { admin_auth_headers(current_admin) }
  let(:video_post) { create(:post, tenant: tenant, user: student, admin: nil) }
  let(:foreign_post) { create(:post, tenant: other_tenant, user: nil, admin: create(:admin, tenant: other_tenant)) }
  let(:base_path) { "/api/v1/admin/posts/#{video_post.id}/comments" }

  def create_comment(**attributes)
    create(:video_comment, { owner_tenant: tenant, post: video_post, user: nil, admin: current_admin }.merge(attributes))
  end

  def create_foreign_comment
    create(:video_comment, owner_tenant: other_tenant, post: foreign_post, user: create(:user, tenant: other_tenant))
  end

  describe 'GET /api/v1/admin/posts/:post_id/comments' do
    it 'トークン無しは 401' do
      get base_path
      expect(response).to have_http_status(:unauthorized)
    end

    it '受講生トークンは 401' do
      get base_path, headers: user_auth_headers(student)
      expect(response).to have_http_status(:unauthorized)
    end

    it '他テナントの動画は 404' do
      get "/api/v1/admin/posts/#{foreign_post.id}/comments", headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it '存在しない動画は 404' do
      get '/api/v1/admin/posts/0/comments', headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it 'コメントが無ければ空配列' do
      get base_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json).to eq('comments' => [])
    end

    it 'トップレベルを created_at DESC, id DESC で並べる' do
      older = create_comment(created_at: 2.days.ago)
      newer = create_comment(created_at: 1.day.ago)
      same_time_a = create_comment(created_at: 1.hour.ago)
      same_time_b = create_comment(created_at: same_time_a.created_at)

      get base_path, headers: headers

      expect(json['comments'].map { |comment| comment['id'] })
        .to eq([same_time_b, same_time_a, newer, older].map { |comment| comment.id.to_s })
    end

    it 'replies を created_at ASC, id ASC で並べる' do
      top = create_comment
      later = create_comment(parent: top, created_at: 1.hour.ago)
      earlier = create_comment(parent: top, created_at: 2.hours.ago)

      get base_path, headers: headers

      expect(json['comments'].map { |comment| comment['id'] }).to eq([top.id.to_s])
      expect(json['comments'].first['replies'].map { |comment| comment['id'] })
        .to eq([earlier.id.to_s, later.id.to_s])
    end

    it '自分のコメントの JSON のキーと型が仕様どおり' do
      top = create_comment

      get base_path, headers: headers

      comment = json['comments'].first
      expect(comment).to include(
        'id'         => top.id.to_s,
        'postId'     => video_post.id.to_s,
        'parentId'   => nil,
        'content'    => top.content,
        'authorType' => 'admin',
        'authorId'   => current_admin.id.to_s,
        'authorName' => current_admin.name,
        'isMine'     => true,
        'canDelete'  => true,
        'replies'    => []
      )
      expect(comment['createdAt']).to eq(top.created_at.iso8601)
      expect(comment['updatedAt']).to eq(top.updated_at.iso8601)
    end

    it '受講生のコメントは authorType user・isMine false・canDelete true' do
      create_comment(user: student, admin: nil)

      get base_path, headers: headers

      expect(json['comments'].first).to include('authorType' => 'user', 'authorId' => student.id.to_s,
        'authorName' => student.name, 'isMine' => false,
        'canDelete' => true)
    end

    it '他の管理者のコメントは isMine false・canDelete true' do
      create_comment(admin: other_admin)

      get base_path, headers: headers

      expect(json['comments'].first).to include('isMine' => false, 'canDelete' => true)
    end
  end

  describe 'POST /api/v1/admin/posts/:post_id/comments' do
    it 'トークン無しは 401 で DB 不変' do
      expect { post base_path, params: { content: 'a' } }.not_to(change { comment_count })
      expect(response).to have_http_status(:unauthorized)
    end

    it '受講生トークンは 401 で DB 不変' do
      expect { post base_path, params: { content: 'a' }, headers: user_auth_headers(student) }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:unauthorized)
    end

    it '他テナントの動画は 404 で DB 不変' do
      expect { post "/api/v1/admin/posts/#{foreign_post.id}/comments", params: { content: 'a' }, headers: headers }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:not_found)
    end

    it '201 で作成し { comment } を返す' do
      expect { post base_path, params: { content: '講師です' }, headers: headers }
        .to change { comment_count }.by(1)

      expect(response).to have_http_status(:created)
      expect(json['comment']).to include('content' => '講師です', 'parentId' => nil, 'replies' => [],
        'authorType' => 'admin', 'isMine' => true)
    end

    it '投稿者は JWT の本人になり、リクエストの user_id / admin_id / tenant_id は無視される' do
      post base_path, params: { content: 'a', user_id: student.id, admin_id: other_admin.id,
                                tenant_id: other_tenant.id }, headers: headers

      created = VideoComment.unscoped.find(json['comment']['id'])
      expect(created.admin_id).to eq(current_admin.id)
      expect(created.user_id).to be_nil
      expect(created.tenant_id).to eq(tenant.id)
    end

    it '空の content は 422 で DB 不変' do
      expect { post base_path, params: { content: '' }, headers: headers }.not_to(change { comment_count })
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json['errors']).to be_present
    end

    it '1001 字は 422 で DB 不変' do
      expect { post base_path, params: { content: 'a' * 1001 }, headers: headers }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it '受講生のコメントへ返信できる' do
      top = create_comment(user: student, admin: nil)

      expect { post base_path, params: { content: '返信', parent_id: top.id }, headers: headers }
        .to change { comment_count }.by(1)

      expect(response).to have_http_status(:created)
      expect(json['comment']['parentId']).to eq(top.id.to_s)
    end

    it '返信への返信は parentId がトップレベルの id になる' do
      top = create_comment
      reply = create_comment(parent: top)

      post base_path, params: { content: '孫', parent_id: reply.id }, headers: headers

      expect(response).to have_http_status(:created)
      expect(json['comment']['parentId']).to eq(top.id.to_s)
    end

    it 'content に配列を送ると 422 で DB 不変' do
      json_headers = headers.merge('CONTENT_TYPE' => 'application/json')
      expect { post base_path, params: { content: ['a'] }.to_json, headers: json_headers }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it '他の動画のコメントを parent_id にすると 404 で DB 不変' do
      other_post = create(:post, tenant: tenant, user: student, admin: nil)
      foreign_parent = create_comment(post: other_post)

      expect { post base_path, params: { content: 'a', parent_id: foreign_parent.id }, headers: headers }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:not_found)
    end

    it '他テナントのコメントを parent_id にすると 404 で DB 不変' do
      foreign_parent = create_foreign_comment

      expect { post base_path, params: { content: 'a', parent_id: foreign_parent.id }, headers: headers }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:not_found)
    end

    it '存在しない parent_id は 404 で DB 不変' do
      expect { post base_path, params: { content: 'a', parent_id: 0 }, headers: headers }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'PATCH /api/v1/admin/posts/:post_id/comments/:id' do
    let!(:own_comment) { create_comment(content: '元の本文') }

    it 'トークン無しは 401 で DB 不変' do
      patch "#{base_path}/#{own_comment.id}", params: { content: '変更' }
      expect(response).to have_http_status(:unauthorized)
      expect(own_comment.reload.content).to eq('元の本文')
    end

    it '受講生トークンは 401 で DB 不変' do
      patch "#{base_path}/#{own_comment.id}", params: { content: '変更' }, headers: user_auth_headers(student)
      expect(response).to have_http_status(:unauthorized)
      expect(own_comment.reload.content).to eq('元の本文')
    end

    it '本人は 200 で編集できる' do
      patch "#{base_path}/#{own_comment.id}", params: { content: '変更後' }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json['comment']).to include('id' => own_comment.id.to_s, 'content' => '変更後')
      expect(own_comment.reload.content).to eq('変更後')
    end

    it '他の管理者のコメントは 404 で DB 不変' do
      others = create_comment(admin: other_admin, content: '他の講師')

      patch "#{base_path}/#{others.id}", params: { content: '乗っ取り' }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(others.reload.content).to eq('他の講師')
    end

    it '受講生のコメントは 404 で DB 不変' do
      students_comment = create_comment(user: student, admin: nil, content: '受講生')

      patch "#{base_path}/#{students_comment.id}", params: { content: '乗っ取り' }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(students_comment.reload.content).to eq('受講生')
    end

    it '他テナントのコメントは 404 で DB 不変' do
      foreign_comment = create_foreign_comment
      original = foreign_comment.content

      patch "/api/v1/admin/posts/#{foreign_post.id}/comments/#{foreign_comment.id}",
        params: { content: '乗っ取り' }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(foreign_comment.reload.content).to eq(original)
    end

    it '空の content は 422 で DB 不変' do
      patch "#{base_path}/#{own_comment.id}", params: { content: '' }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(own_comment.reload.content).to eq('元の本文')
    end

    it '1001 字は 422 で DB 不変' do
      patch "#{base_path}/#{own_comment.id}", params: { content: 'a' * 1001 }, headers: headers

      expect(response).to have_http_status(:unprocessable_entity)
      expect(own_comment.reload.content).to eq('元の本文')
    end
  end

  describe 'DELETE /api/v1/admin/posts/:post_id/comments/:id' do
    let!(:own_comment) { create_comment }

    it 'トークン無しは 401 で DB 不変' do
      expect { delete "#{base_path}/#{own_comment.id}" }.not_to(change { comment_count })
      expect(response).to have_http_status(:unauthorized)
    end

    it '受講生トークンは 401 で DB 不変' do
      expect { delete "#{base_path}/#{own_comment.id}", headers: user_auth_headers(student) }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:unauthorized)
    end

    it '自分のコメントを 204 で削除できる' do
      expect { delete "#{base_path}/#{own_comment.id}", headers: headers }.to change { comment_count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it '同テナントの受講生のコメントを削除できる' do
      students_comment = create_comment(user: student, admin: nil)

      expect { delete "#{base_path}/#{students_comment.id}", headers: headers }.to change { comment_count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it '同テナントの他の管理者のコメントを削除できる' do
      others = create_comment(admin: other_admin)

      expect { delete "#{base_path}/#{others.id}", headers: headers }.to change { comment_count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it '他テナントのコメントは 404 で DB 不変' do
      foreign_comment = create_foreign_comment

      expect { delete "/api/v1/admin/posts/#{foreign_post.id}/comments/#{foreign_comment.id}", headers: headers }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:not_found)
    end

    it 'トップレベルを消すと返信も消える' do
      create_comment(parent: own_comment, user: student, admin: nil)

      expect { delete "#{base_path}/#{own_comment.id}", headers: headers }.to change { comment_count }.by(-2)
    end

    it '別の動画の path 経由では 404 で DB 不変' do
      other_post = create(:post, tenant: tenant, user: student, admin: nil)

      expect { delete "/api/v1/admin/posts/#{other_post.id}/comments/#{own_comment.id}", headers: headers }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:not_found)
    end
  end
end
