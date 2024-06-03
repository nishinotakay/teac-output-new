class Users::SubscriptionsController < Users::Base

  def new
    @charge_plan = ChargePlan.find_by(charge_type: "定額決済")
  end

  def create
    customer = ensure_stripe_customer
    session = create_session(customer)
    render json: { session: session }, status: :ok
  end

  private

  def ensure_stripe_customer
    return Stripe::Customer.retrieve(current_user.stripe_customer_id) if current_user.stripe_customer_id
    customer = Stripe::Customer.create(email: current_user.email)
    current_user.update(stripe_customer_id: customer.id)
  end

  def create_session(customer)
    @charge_plan = ChargePlan.find_by(charge_type: "定額決済")
    session = Stripe::Checkout::Session.create(
      customer: customer.id,
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
