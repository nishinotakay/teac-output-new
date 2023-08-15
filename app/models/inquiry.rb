class Inquiry < ApplicationRecord
  belongs_to :user

  validates :subject, presence: true, length: { maximum: 30 }
  validates :content, presence: true, length: { maximum: 800 }

  def self.get_sort_and_filter_params(params)
    order = {
      subject: params[:ord_subject], 
      content: params[:ord_content], 
      created_at: params[:ord_created_at]
    }.compact
    filter = {
      subject: params[:flt_subject], 
      content: params[:flt_content],
      created_at: params[:flt_created_at],
      hidden: params[:flt_hidden]
    }.compact
    sort_and_filter_params = {order: order, filter: filter}
    return sort_and_filter_params
  end
  
  def self.get_inquiries(sort_and_filter_params)
    if sort_and_filter_params[:filter][:hidden] == "1"
      inquiries = where(hidden: false)
    elsif sort_and_filter_params[:filter][:hidden] == "2"
      hidden = where(hidden: true)
    elsif sort_and_filter_params[:filter][:hidden] == "3"
      both = where(hidden: [true, false])
    else
      inquiries = where(hidden: false)
    end
    [inquiries, hidden, both]
  end
  
  def self.apply_sort_and_filter(inquiry_scope, sort_and_filter_params)
    inquiry_scope = inquiry_scope.order(sort_and_filter_params[:order])
    if sort_and_filter_params[:filter][:subject].present?
      inquiry_scope = inquiry_scope.where("subject LIKE ?", "%#{sort_and_filter_params[:filter][:subject]}%")
    end
    if sort_and_filter_params[:filter][:content].present?
      inquiry_scope = inquiry_scope.where("content LIKE ?", "%#{sort_and_filter_params[:filter][:content]}%")
    end
    if sort_and_filter_params[:filter][:created_at].present?
      created_at_date = Date.parse(sort_and_filter_params[:filter][:created_at]).strftime('%Y-%m-%d')
      inquiry_scope = inquiry_scope.where("DATE(created_at) = ?", created_at_date)
    end
    
    inquiry_scope
  end
end
