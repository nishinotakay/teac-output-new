module Admins
  class InquiriesController < Admins::Base
    def index
      filter = {subject: params[:flt_subject], content: params[:flt_content],created_at: params[:fit_created_at],hidden: params[:flt_hidden]}.compact
      filter.delete(:hidden)
      order = {subject: params[:ord_subject], content: params[:ord_content], created_at: params[:ord_created_at]}.compact
      
      if params[:flt_hidden].present? && params[:flt_hidden] == "1"
         @hidden = Inquiry.where(hidden: true).order(order)
                         .where("subject LIKE ?", "%#{params[:flt_subject]}%")
                         .where("content LIKE ?", "%#{params[:flt_content]}%")
        if params[:flt_created_at].present?
          @hidden = Inquiry.where("DATE(created_at) = ?", 
          Date.parse(params[:flt_created_at]).strftime('%Y-%m-%d')) || params[:flt_subject].present? || params[:flt_content].present?
        end
        elsif params[:flt_hidden].present? && params[:flt_hidden] == "2"
          @inquiries = Inquiry.where(hidden: [true, false]).order(order)
          .where("subject LIKE ?", "%#{params[:flt_subject]}%")
          .where("content LIKE ?", "%#{params[:flt_content]}%")
          if params[:flt_created_at].present?
            @inquiries = @inquiries.where("DATE(created_at) = ?", 
            Date.parse(params[:flt_created_at]).strftime('%Y-%m-%d')) || params[:flt_subject].present? || params[:flt_content].present?
          end
        else
          @inquiries = Inquiry.where(hidden: false).order(order)
          .where("subject LIKE ?", "%#{params[:flt_subject]}%")
          .where("content LIKE ?", "%#{params[:flt_content]}%")
          if params[:flt_created_at].present?
            @inquiries = @inquiries.where("DATE(created_at) = ?", 
              Date.parse(params[:flt_created_at]).strftime('%Y-%m-%d')) || params[:flt_subject].present? || params[:flt_content].present?
          end
      end
    end


    def show
      @inquiry = Inquiry.find(params[:id])
    end

    def update
      @inquiries = Inquiry.find(params[:id])
      if @inquiries.update(hidden: true)
         flash[:notice] = 'お問い合わせを非表示にしました'
         redirect_to admins_inquiries_path
      else
        flash[:notice] = 'お問い合わせを表示しました'
      end
    end
  
    private


    def inquiry_params
      params.require(:inquiry).permit(:subject, :content)
    end
    
  end
end
