class Post < ApplicationRecord
  belongs_to :admin, optional: true
  belongs_to :user, optional: true

  validates :user_id, presence: true, if: -> { admin_id.blank? }
  validates :admin_id, presence: true, if: -> { user_id.blank? }
  validates :title, presence: true, length: { maximum: 30 }
  validates :body, presence: true, length: { maximum: 240 }
  validates :youtube_url, presence: true

  def self.filtered_and_ordered_posts(params, page, per_page)
    params[:order] ||= 'DESC'
    filter = {
      author: params[:author],
      body:   params[:body],
      title:  params[:title],
      start:  params[:start],
      finish: params[:finish],
      order:  params[:order]
    }
    posts = self.includes(:user, :admin)

    if params.present?
      posts = posts.apply_filters(params)
    end

    posts.order(created_at: 'DESC').page(page).per(per_page)
  end

  def self.apply_filters(filter)
    start = Time.zone.parse(filter[:start].presence || '2022-01-01').beginning_of_day
    finish = Time.zone.parse(filter[:finish].presence || Date.current.to_s).end_of_day

    left_joins(:user, :admin)
      .where(['title LIKE ? AND body LIKE ?',
              "%#{filter[:title]}%", "%#{filter[:body]}%"])
      .where('posts.created_at BETWEEN ? AND ?', start, finish)
      .where('users.name LIKE :author OR admins.name LIKE :author', author: "%#{filter[:author]}%")
      .order(Arel.sql("posts.created_at #{filter[:order]}"))
      .presence || Post.none
  end 
end
