module Admins
  class InquiriesController < Admins::Base
    def index
      params[:ord_created_at] ||= 'desc'
      sort_and_filter_params = Inquiry.sort_and_filter(params)
      @inquiries, @hidden, @both = Inquiry.hidden_params(sort_and_filter_params)
      [@inquiries, @hidden, @both].compact.each do |inquiry_hidden|
        @inquiry_scope = Inquiry.inquiry_filter(inquiry_hidden, sort_and_filter_params).order('inquiries.created_at': params[:ord_created_at])
      end
      @users = User.page(params[:page]).per(30)
    end

    def show
      @inquiry = Inquiry.find(params[:id])
      @user = @inquiry.user 
    end

    def update
      @inquiry = Inquiry.find(params[:id])
      if @inquiry.update(hidden: !@inquiry.hidden)
        if @inquiry.hidden
          flash[:notice] = 'お問い合わせを非表示にしました'
        else
          flash[:notice] = 'お問い合わせを再表示しました'
        end
      end
      redirect_to admins_inquiries_path
    end
  
    private

    def inquiry_params
      params.require(:inquiry).permit(:subject, :content)
    end    
  end
end
