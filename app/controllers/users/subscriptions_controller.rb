class Users::SubscriptionsController < Users::Base

  def new
    @charge_plan = ChargePlan.find_by(charge_type: "定額決済")
  end

  def create
    session = create_session
    render json: { session: session }, status: :ok
  end

  private 

  def create_session
    @charge_plan = ChargePlan.find_by(charge_type: "定額決済")
    session = Stripe::Checkout::Session.create(
      customer_email: current_user.email,
      mode: 'subscription',
      payment_method_types: ['card'],
      line_items: [{
        price: @charge_plan.stripe_plan_id,
        quantity: 1,
      }],
      success_url: Rails.application.routes.url_helpers.users_user_payments_url(current_user, host: '0.0.0.0:3000'),
      cancel_url: 'http://0.0.0.0:3000/users/subscriptions/new'
    )
  end

end
