# 管理者向けお問い合わせコントローラ: お問い合わせの一覧表示・詳細確認・表示/非表示切り替えを管理する

module Admins
  class InquiriesController < Admins::Base
    # お問い合わせ一覧をフィルタ・ソート付きで表示する
    def index
      params[:ord_created_at] ||= 'desc'
      sort_and_filter_params = Inquiry.sort_and_filter(params)
      @inquiries, @hidden, @both = Inquiry.hidden_params(sort_and_filter_params)
      [@inquiries, @hidden, @both].compact.each do |inquiry_hidden|
        @inquiry_scope = Inquiry.inquiry_filter(inquiry_hidden, sort_and_filter_params).order('inquiries.created_at': params[:ord_created_at])
      end
      @users = User.page(params[:page]).per(30)
    end

    # お問い合わせの詳細と送信ユーザーを表示する
    def show
      @inquiry = Inquiry.find(params[:id])
      @user = @inquiry.user
    end

    # お問い合わせの表示/非表示状態をトグルする
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
