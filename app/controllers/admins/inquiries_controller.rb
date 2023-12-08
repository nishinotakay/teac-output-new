module Admins
  class InquiriesController < Admins::Base
    def index
      sort_and_filter_params = Inquiry.get_sort_and_filter_params(params)
      @inquiries, @hidden, @both = Inquiry.get_inquiries(sort_and_filter_params)
      [@inquiries, @hidden, @both].compact.each do |inquiry_scope|
        @inquiry_scope = Inquiry.apply_sort_and_filter(inquiry_scope, sort_and_filter_params).order(created_at: :desc)
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
          flash[:notice] = 'お問い合わせを表示しました'
        end
      else
        flash[:alert] = '更新に失敗しました'
      end
      redirect_to admins_inquiries_path
    end
  
    private


    def inquiry_params
      params.require(:inquiry).permit(:subject, :content)
    end
    
  end
end
