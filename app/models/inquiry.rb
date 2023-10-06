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
      hidden: params[:flt_hidden],
      start: params[:flt_start],
      finish: params[:flt_finish]
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
    if sort_and_filter_params[:filter][:start].present? || sort_and_filter_params[:filter][:finish].present?
      inquiry_scope = inquiry_scope.where('created_at BETWEEN ? AND ?', sort_and_filter_params[:filter][:start], sort_and_filter_params[:filter][:finish])
    end  
    inquiry_scope
  end
end
