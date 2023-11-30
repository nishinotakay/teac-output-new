module Admins
  class InquiriesController < Admins::Base
    def index
      sort_and_filter_params = Inquiry.sort_and_filter(params)
      @inquiries, @hidden, @both = Inquiry.hidden_params(sort_and_filter_params)
      [@inquiries, @hidden, @both].compact.each do |inquiry_hidden|
        @inquiry_scope = Inquiry.inquiry_filter(inquiry_hidden, sort_and_filter_params).order(created_at: params[:ord_created_at])
      end
      @users = User.page(params[:page]).per(30)
    end

    def show
      @inquiry = Inquiry.find(params[:id])
      @user = @inquiry.user 
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
