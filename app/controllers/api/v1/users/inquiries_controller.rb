class Api::V1::Users::InquiriesController < Api::V1::BaseController
  before_action :authenticate_user!
  before_action :set_inquiry, only: [:show]

  # GET /api/v1/inquiries
  def index
    inquiries = @current_user.inquiries.order(created_at: :desc)
    render json: { inquiries: inquiries.map { |i| inquiry_json(i) } }
  end

  # GET /api/v1/inquiries/:id
  def show
    unless @inquiry.user_id == @current_user.id
      return render json: { error: '権限がありません' }, status: :forbidden
    end

    render json: { inquiry: inquiry_json(@inquiry) }
  end

  # POST /api/v1/inquiries
  def create
    inquiry = @current_user.inquiries.build(inquiry_params)
    if inquiry.save
      render json: { inquiry: inquiry_json(inquiry) }, status: :created
    else
      render json: { errors: inquiry.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_inquiry
    @inquiry = Inquiry.find_by(id: params[:id])
    render_not_found('問い合わせ') unless @inquiry
  end

  def inquiry_params
    params.permit(:subject, :content)
  end

  def inquiry_json(inquiry)
    {
      id: inquiry.id.to_s,
      subject: inquiry.subject,
      content: inquiry.content,
      hidden: inquiry.hidden,
      userId: inquiry.user_id.to_s,
      createdAt: inquiry.created_at.iso8601
    }
  end
end
