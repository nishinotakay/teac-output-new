require 'rails_helper'

RSpec.describe 'Api::V1::Users::VideoComments', type: :request do
  def user_auth_headers(user)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: user.id, role: 'user')}" }
  end

  def admin_auth_headers(admin)
    { 'Authorization' => "Bearer #{JwtHelper.encode(id: admin.id, role: 'admin')}" }
  end

  def json
    JSON.parse(response.body)
  end

  def comment_count
    VideoComment.unscoped.count
  end

  let(:tenant) { create(:tenant) }
  let(:other_tenant) { create(:tenant) }
  let(:current_user) { create(:user, tenant: tenant) }
  let(:other_student) { create(:user, tenant: tenant) }
  let(:tenant_admin) { create(:admin, tenant: tenant) }
  let(:headers) { user_auth_headers(current_user) }
  let(:video_post) { create(:post, tenant: tenant, user: nil, admin: tenant_admin) }
  let(:foreign_post) { create(:post, tenant: other_tenant, user: nil, admin: create(:admin, tenant: other_tenant)) }
  let(:base_path) { "/api/v1/posts/#{video_post.id}/comments" }

  def create_comment(**attributes)
    create(:video_comment, { owner_tenant: tenant, post: video_post, user: current_user }.merge(attributes))
  end

  describe 'GET /api/v1/posts/:post_id/comments' do
    it 'トークン無しは 401' do
      get base_path
      expect(response).to have_http_status(:unauthorized)
    end

    it '管理者トークンは 401' do
      get base_path, headers: admin_auth_headers(tenant_admin)
      expect(response).to have_http_status(:unauthorized)
    end

    it '他テナントの動画は 404' do
      get "/api/v1/posts/#{foreign_post.id}/comments", headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it '存在しない動画は 404' do
      get '/api/v1/posts/0/comments', headers: headers
      expect(response).to have_http_status(:not_found)
    end

    it '200 で { comments: [...] } を返す' do
      create_comment

      get base_path, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json['comments'].size).to eq(1)
    end

    it 'コメントが無ければ空配列' do
      get base_path, headers: headers

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

    it 'トップレベルだけが comments に並び、返信は replies に入る' do
      top = create_comment
      reply = create_comment(parent: top)

      get base_path, headers: headers

      expect(json['comments'].map { |comment| comment['id'] }).to eq([top.id.to_s])
      expect(json['comments'].first['replies'].map { |comment| comment['id'] }).to eq([reply.id.to_s])
    end

    it 'replies を created_at ASC, id ASC で並べる' do
      top = create_comment
      later = create_comment(parent: top, created_at: 1.hour.ago)
      earlier = create_comment(parent: top, created_at: 2.hours.ago)

      get base_path, headers: headers

      expect(json['comments'].first['replies'].map { |comment| comment['id'] })
        .to eq([earlier.id.to_s, later.id.to_s])
    end

    it '他の動画のコメントを含まない' do
      create_comment(post: create(:post, tenant: tenant, user: nil, admin: tenant_admin))

      get base_path, headers: headers

      expect(json['comments']).to eq([])
    end

    it 'JSON のキーと型が仕様どおり' do
      top = create_comment

      get base_path, headers: headers

      comment = json['comments'].first
      expect(comment).to include(
        'id'         => top.id.to_s,
        'postId'     => video_post.id.to_s,
        'parentId'   => nil,
        'content'    => top.content,
        'authorType' => 'user',
        'authorId'   => current_user.id.to_s,
        'authorName' => current_user.name,
        'isMine'     => true,
        'canDelete'  => true,
        'replies'    => []
      )
      expect(comment['createdAt']).to eq(top.created_at.iso8601)
      expect(comment['updatedAt']).to eq(top.updated_at.iso8601)
    end

    it '返信の parentId はトップレベルの id（文字列）' do
      top = create_comment
      create_comment(parent: top)

      get base_path, headers: headers

      expect(json['comments'].first['replies'].first['parentId']).to eq(top.id.to_s)
    end

    it '管理者のコメントは authorType admin・isMine false・canDelete false' do
      create_comment(user: nil, admin: tenant_admin)

      get base_path, headers: headers

      comment = json['comments'].first
      expect(comment).to include('authorType' => 'admin', 'authorId' => tenant_admin.id.to_s,
        'authorName' => tenant_admin.name, 'isMine' => false, 'canDelete' => false)
    end

    it '他の受講生のコメントは isMine false・canDelete false' do
      create_comment(user: other_student)

      get base_path, headers: headers

      expect(json['comments'].first).to include('isMine' => false, 'canDelete' => false)
    end
  end

  describe 'POST /api/v1/posts/:post_id/comments' do
    it 'トークン無しは 401 で DB 不変' do
      expect { post base_path, params: { content: 'a' } }.not_to(change { comment_count })
      expect(response).to have_http_status(:unauthorized)
    end

    it '管理者トークンは 401 で DB 不変' do
      expect { post base_path, params: { content: 'a' }, headers: admin_auth_headers(tenant_admin) }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:unauthorized)
    end

    it '他テナントの動画は 404 で DB 不変' do
      expect { post "/api/v1/posts/#{foreign_post.id}/comments", params: { content: 'a' }, headers: headers }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:not_found)
    end

    it '201 で作成し { comment } を返す' do
      expect { post base_path, params: { content: 'こんにちは' }, headers: headers }
        .to change { comment_count }.by(1)

      expect(response).to have_http_status(:created)
      expect(json['comment']).to include('content' => 'こんにちは', 'parentId' => nil, 'replies' => [],
        'authorType' => 'user', 'isMine' => true)
    end

    it '投稿者は JWT の本人になり、リクエストの user_id / admin_id / tenant_id は無視される' do
      post base_path, params: { content: 'a', user_id: other_student.id, admin_id: tenant_admin.id,
                                tenant_id: other_tenant.id }, headers: headers

      created = VideoComment.unscoped.find(json['comment']['id'])
      expect(created.user_id).to eq(current_user.id)
      expect(created.admin_id).to be_nil
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

    it '1000 字は 201' do
      post base_path, params: { content: 'a' * 1000 }, headers: headers
      expect(response).to have_http_status(:created)
    end

    it 'parent_id 付きで返信を作成できる' do
      top = create_comment

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

    it '他の動画のコメントを parent_id にすると 4xx で DB 不変' do
      other_post = create(:post, tenant: tenant, user: nil, admin: tenant_admin)
      foreign_parent = create_comment(post: other_post)

      expect { post base_path, params: { content: 'a', parent_id: foreign_parent.id }, headers: headers }
        .not_to(change { comment_count })
      expect(response.status).to be_between(400, 499)
    end

    it '他テナントのコメントを parent_id にすると 4xx で DB 不変' do
      foreign_parent = create(:video_comment, owner_tenant: other_tenant, post: foreign_post,
        user: create(:user, tenant: other_tenant))

      expect { post base_path, params: { content: 'a', parent_id: foreign_parent.id }, headers: headers }
        .not_to(change { comment_count })
      expect(response.status).to be_between(400, 499)
    end

    it '存在しない parent_id は 4xx で DB 不変' do
      expect { post base_path, params: { content: 'a', parent_id: 0 }, headers: headers }
        .not_to(change { comment_count })
      expect(response.status).to be_between(400, 499)
    end
  end

  describe 'PATCH /api/v1/posts/:post_id/comments/:id' do
    let!(:own_comment) { create_comment(content: '元の本文') }

    it 'トークン無しは 401 で DB 不変' do
      patch "#{base_path}/#{own_comment.id}", params: { content: '変更' }
      expect(response).to have_http_status(:unauthorized)
      expect(own_comment.reload.content).to eq('元の本文')
    end

    it '管理者トークンは 401 で DB 不変' do
      patch "#{base_path}/#{own_comment.id}", params: { content: '変更' }, headers: admin_auth_headers(tenant_admin)
      expect(response).to have_http_status(:unauthorized)
      expect(own_comment.reload.content).to eq('元の本文')
    end

    it '本人は 200 で編集できる' do
      patch "#{base_path}/#{own_comment.id}", params: { content: '変更後' }, headers: headers

      expect(response).to have_http_status(:ok)
      expect(json['comment']).to include('id' => own_comment.id.to_s, 'content' => '変更後')
      expect(own_comment.reload.content).to eq('変更後')
    end

    it '他の受講生のコメントは 404 で DB 不変' do
      others = create_comment(user: other_student, content: '他人')

      patch "#{base_path}/#{others.id}", params: { content: '乗っ取り' }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(others.reload.content).to eq('他人')
    end

    it '管理者のコメントは 404 で DB 不変' do
      admins_comment = create_comment(user: nil, admin: tenant_admin, content: '講師')

      patch "#{base_path}/#{admins_comment.id}", params: { content: '乗っ取り' }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(admins_comment.reload.content).to eq('講師')
    end

    it '他テナントのコメントは 404 で DB 不変' do
      foreign_comment = create(:video_comment, owner_tenant: other_tenant, post: foreign_post,
        user: create(:user, tenant: other_tenant), content: '他社')

      patch "/api/v1/posts/#{foreign_post.id}/comments/#{foreign_comment.id}",
        params: { content: '乗っ取り' }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(foreign_comment.reload.content).to eq('他社')
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

    it '別の動画の path 経由では 404' do
      other_post = create(:post, tenant: tenant, user: nil, admin: tenant_admin)

      patch "/api/v1/posts/#{other_post.id}/comments/#{own_comment.id}", params: { content: '変更' }, headers: headers

      expect(response).to have_http_status(:not_found)
      expect(own_comment.reload.content).to eq('元の本文')
    end
  end

  describe 'DELETE /api/v1/posts/:post_id/comments/:id' do
    let!(:own_comment) { create_comment }

    it 'トークン無しは 401 で DB 不変' do
      expect { delete "#{base_path}/#{own_comment.id}" }.not_to(change { comment_count })
      expect(response).to have_http_status(:unauthorized)
    end

    it '管理者トークンは 401 で DB 不変' do
      expect { delete "#{base_path}/#{own_comment.id}", headers: admin_auth_headers(tenant_admin) }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:unauthorized)
    end

    it '本人は 204 で削除できる' do
      expect { delete "#{base_path}/#{own_comment.id}", headers: headers }.to change { comment_count }.by(-1)

      expect(response).to have_http_status(:no_content)
    end

    it '他の受講生のコメントは 404 で DB 不変' do
      others = create_comment(user: other_student)

      expect { delete "#{base_path}/#{others.id}", headers: headers }.not_to(change { comment_count })
      expect(response).to have_http_status(:not_found)
    end

    it '管理者のコメントは 404 で DB 不変' do
      admins_comment = create_comment(user: nil, admin: tenant_admin)

      expect { delete "#{base_path}/#{admins_comment.id}", headers: headers }.not_to(change { comment_count })
      expect(response).to have_http_status(:not_found)
    end

    it '他テナントのコメントは 404 で DB 不変' do
      foreign_comment = create(:video_comment, owner_tenant: other_tenant, post: foreign_post,
        user: create(:user, tenant: other_tenant))

      expect { delete "/api/v1/posts/#{foreign_post.id}/comments/#{foreign_comment.id}", headers: headers }
        .not_to(change { comment_count })
      expect(response).to have_http_status(:not_found)
    end

    it 'トップレベルを消すと返信も消える' do
      create_comment(parent: own_comment, user: other_student)

      expect { delete "#{base_path}/#{own_comment.id}", headers: headers }.to change { comment_count }.by(-2)
    end

    it '返信だけを消してもトップレベルは残る' do
      reply = create_comment(parent: own_comment)

      delete "#{base_path}/#{reply.id}", headers: headers

      expect(VideoComment.unscoped.exists?(own_comment.id)).to be(true)
    end
  end
end
