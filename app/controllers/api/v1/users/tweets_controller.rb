class Api::V1::Users::TweetsController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_tweet, only: [:show, :update, :destroy]

  # GET /api/v1/tweets
  def index
    tweets = Tweet.order(created_at: :desc)
    render json: { tweets: tweets.map { |t| tweet_json(t) } }
  end

  # GET /api/v1/tweets/:id
  def show
    render json: { tweet: tweet_json(@tweet) }
  end

  # POST /api/v1/tweets
  def create
    tweet = @current_user.tweets.build(tweet_params)
    if tweet.save
      render json: { tweet: tweet_json(tweet) }, status: :created
    else
      render json: { errors: tweet.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /api/v1/tweets/:id
  def update
    unless @tweet.user_id == @current_user.id
      return render json: { error: '権限がありません' }, status: :forbidden
    end

    if @tweet.update(tweet_params)
      render json: { tweet: tweet_json(@tweet) }
    else
      render json: { errors: @tweet.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /api/v1/tweets/:id
  def destroy
    unless @tweet.user_id == @current_user.id
      return render json: { error: '権限がありません' }, status: :forbidden
    end

    @tweet.destroy
    render json: { message: '削除しました' }
  end

  private

  def set_tweet
    @tweet = Tweet.find_by(id: params[:id])
    render_not_found('つぶやき') unless @tweet
  end

  def tweet_params
    params.permit(:post)
  end

  def tweet_json(tweet)
    {
      id: tweet.id.to_s,
      post: tweet.post,
      userId: tweet.user_id.to_s,
      createdAt: tweet.created_at.iso8601,
      updatedAt: tweet.updated_at.iso8601
    }
  end
end
