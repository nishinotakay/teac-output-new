# ユーザー向けお問い合わせコントローラ: ユーザーがお問い合わせを投稿・閲覧するアクションを提供する

module Users
  class InquiriesController < Users::Base
    # お問い合わせ一覧を表示する
    def index
      @inquiry = Inquiry.all
    end

    # お問い合わせ詳細を表示する
    def show; end

    # 新規お問い合わせフォームを表示する
    def new
      @inquiry = current_user.inquiries.new
    end

    # 新規お問い合わせを保存する
    def create
      @inquiry = current_user.inquiries.new(inquiry_params)
      if @inquiry.save
        redirect_to new_users_inquiry_path, flash: { success: '問い合わせを投稿しました。' }
      else
        flash.now[:error] = '問い合わせ投稿出来ませんでした。'
        render :new
      end
    end

    private

    def inquiry_params
      params.require(:inquiry).permit(:subject, :content)
    end
  end
end
