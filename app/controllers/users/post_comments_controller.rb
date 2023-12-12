module Users
  class PostCommentsController < Users::Base
    before_action :authenticate_user!, only: %i[create destroy update]
    before_action :set_post
    before_action :set_post_comment, only: %i[destroy update]

    def create
      @post_comment = current_user.post_comments.new(post_comment_params.merge(post: @post))
      if @post_comment.save
        redirect_back(fallback_location: users_post_path(@post)) #コメント送信後は、一つ前のページへリダイレクトさせる。
      else
        redirect_back(fallback_location: users_post_path(@post))
      end
    end

    def update
      if @post_comment.update(post_comment_params)
        flash[:success] = 'コメントを更新しました。'
      else
        flash[:danger] = @post_comment.errors.full_messages.join(', ')
      end
      redirect_to users_post_path(@post)
    end

    def destroy
      if @post_comment.destroy
        redirect_to users_post_url(@post), success: 'コメントを削除しました。'
      else
        redirect_to users_post_url(@post), notice: 'コメント削除に失敗しました。'
      end
    end

    private

      def set_post
        @post = Post.find(params[:post_id])
      end

      def set_post_comment
        @post_comment = current_user.post_comments.find(params[:id])
      end

      def post_comment_params
        params.require(:post_comment).permit(:content, :post_id)
      end
  end
end
