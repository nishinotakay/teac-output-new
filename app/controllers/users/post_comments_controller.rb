module Users
  class PostCommentsController < Users::Base
    before_action :authenticate_user!, only: %i[create destroy update]

    def create
      @post = Post.find(params[:post_id])
      @post_comment = current_user.post_comments.new(post_comment_params.merge(post: @post))
      # binding.irb
      if @post_comment.save
        redirect_back(fallback_location: users_post_path(@post)) #コメント送信後は、一つ前のページへリダイレクトさせる。
      else
        redirect_back(fallback_location: users_post_path(@post))
      end
    end

    def update
    end

    def destroy
    end

    private
      def post_comment_params
        params.require(:post_comment).permit(:content, :post_id)
      end
  end
end
