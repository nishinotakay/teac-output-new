class Users::PaymentsController < Users::Base
  before_action :authenticate_user!
  before_action :verify_payment_user, only: %i[index]

  def index
    if current_user.stripe_customer_id
      @charges = Stripe::Charge.list(customer: current_user.stripe_customer_id)
      @subscriptions = Stripe::Subscription.list(customer: current_user.stripe_customer_id)
      @payments = combine_payments(@charges.data, @subscriptions.data)
    else
      @payments = []
    end
  end

    private

    def combine_payments(charges, subscriptions)
      combined = []
      charges.each do |charge|
        combined << { type: 'charge', data: charge }
      end
      subscriptions.each do |subscription|
        combined << { type: 'subscription', data: subscription }
      end
        combined.sort_by{ |payment| payment[:data].created }
    end

    def verify_payment_user
      unless current_user.id.to_s == params[:user_id]
        redirect_to users_dash_boards_path
      end
    end
    
end
