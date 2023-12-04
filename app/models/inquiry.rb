class Inquiry < ApplicationRecord
  belongs_to :user

  def self.sort_and_filter(params)
    order = {
      created_at: params[:ord_created_at],
    }
    filter = {
      user_name: params[:flt_user_name],
      hidden: params[:flt_hidden],
      start: params[:flt_start],
      finish: params[:flt_finish]
    }
    
    sort_and_filter = {order: order, filter: filter}
    return sort_and_filter
  end
  
  def self.hidden_params(sort_and_filter)
    if sort_and_filter [:filter][:hidden] == "1"
      inquiries = where(hidden: false)
    elsif sort_and_filter [:filter][:hidden] == "2"
      hidden = where(hidden: true)
    elsif sort_and_filter [:filter][:hidden] == "3"
      both = where(hidden: [true, false])
    else
      inquiries = where(hidden: false)
    end
    [inquiries, hidden, both]
  end

  def self.inquiry_filter(inquiry_filter, sort_and_filter)
    if sort_and_filter[:filter][:user_name].present?
      inquiry_filter = inquiry_filter.joins(:user).where("users.name LIKE ?", "%#{sort_and_filter[:filter][:user_name]}%")
    end
    if sort_and_filter[:filter][:start].present? || sort_and_filter [:filter][:finish].present?
      start = Time.zone.parse(sort_and_filter[:filter][:start].presence || '2022-01-01').beginning_of_day
      finish = Time.zone.parse(sort_and_filter[:filter][:finish].presence || Date.current.to_s).end_of_day
      inquiry_filter = inquiry_filter.where('created_at BETWEEN ? AND ?', start, finish)
    end  
    return inquiry_filter
  end
end
