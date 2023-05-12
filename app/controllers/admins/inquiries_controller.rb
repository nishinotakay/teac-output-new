module Admins
  class InquiriesController < Admins::Base
    def index
      filter = { subject: params[:flt_subject], content: params[:flt_content], created_at: params[:fit_created_at],
hidden: params[:flt_hidden] }.compact
      order = { subject: params[:ord_subject], content: params[:ord_content], created_at: params[:ord_created_at] }.compact
      if params[:flt_hidden] == '1'
        @inquiries = Inquiry.where(hidden: true)
      elsif params[:flt_hidden] == '2'
        @hidden = Inquiry.where(hidden: false)
      elsif params[:flt_hidden] == '3'
        @both = Inquiry.where(hidden: [true, false])
      else
        @inquiries = Inquiry.where(hidden: true)
      end

      [@inquiries, @hidden, @both].compact.each do |inquiry_scope|
        @inquiry_scope = inquiry_scope.order(order)
          .where('subject LIKE ?', "%#{params[:flt_subject]}%")
          .where('content LIKE ?', "%#{params[:flt_content]}%")
        if params[:flt_created_at].present?
          created_at_date = Date.parse(params[:flt_created_at]).strftime('%Y-%m-%d')
          @inquiry_scope = @inquiry_scope.where('DATE(created_at) = ?', created_at_date)
        end
      end
    end

    def show
      @inquiry = Inquiry.find(params[:id])
    end

    def update
      @inquiries = Inquiry.find(params[:id])
      if @inquiries.update(hidden: false)
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
