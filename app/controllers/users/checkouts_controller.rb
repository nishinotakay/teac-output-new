class Users::CheckoutsController < Users::Base
  before_action :authenticate_user!, only: %i[new create]

  def new
  end

  def create
    session = create_session
    render json: { session: session }, status: :ok
  end

  private

  def create_session
    Stripe.api_key = Rails.configuration.stripe[:secret_key]
    Stripe::Checkout::Session.create(
      customer_email: current_user.email,
      mode: 'payment',
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'jpy',
          product_data: {
            name: 'テスト商品',
            description: '受講料',
          },
          unit_amount: 1000,
        },
       quantity: 1,
      }],
      success_url: 'http://0.0.0.0:3000/users/dash_boards?status=success&session_id={CHECKOUT_SESSION_ID}',
      cancel_url: 'http://0.0.0.0:3000/users/dash_boards?status=cancel'
    )
  end
end
