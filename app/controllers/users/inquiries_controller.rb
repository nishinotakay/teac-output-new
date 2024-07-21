module Users
  class InquiriesController < Users::Base
    def index
      @inquiry = Inquiry.all
    end

    def show; end

    def new
      @inquiry = current_user.inquiries.new
    end

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
