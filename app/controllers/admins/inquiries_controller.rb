module Admins
  class InquiriesController < Admins::Base
    def index
      sort_and_filter_params = Inquiry.get_sort_and_filter_params(params)
      @inquiries, @hidden, @both = Inquiry.get_inquiries(sort_and_filter_params)
      [@inquiries, @hidden, @both].compact.each do |inquiry_scope|
        @inquiry_scope = Inquiry.apply_sort_and_filter(inquiry_scope, sort_and_filter_params)
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
