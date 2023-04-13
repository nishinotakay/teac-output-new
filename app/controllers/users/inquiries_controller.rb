module Users
  class InquiriesController < Users::Base
    def index
      @inquiry = Inquiry.where(hidden: false)
    end

    def hide_index
      @inquiry = Inquiry.where(hidden: true)
    end

    def show
    end

    def new
      @inquiry = current_user.inquiries.new
    end

    def create
      @inquiry = current_user.inquiries.new(inquiry_params)
      if @inquiry.save
        redirect_to new_users_inquiry_path , flash: {success: "問い合わせを投稿しました。"}
      else
        flash.now[:danger] = '問い合わせ投稿出来ませんでした。'
        render :new
      end
    end

    def update
      @inquiry = Inquiry.find(params[:id])
      if @inquiry.update(hidden: true)
        flash[:notice] = 'お問い合わせを非表示にしました'
        redirect_to users_inquiries_path
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
