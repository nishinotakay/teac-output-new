class Users::PaymentsController < Users::Base
  before_action :authenticate_user!
  before_action :verify_payment_user, only: %i[index]

  def index
    if current_user.stripe_customer_id
      all_charges = Stripe::Charge.list(customer: current_user.stripe_customer_id).data
      @subscriptions = Stripe::Subscription.list(customer: current_user.stripe_customer_id).data

      subscription_invoice_ids = @subscriptions.map(&:latest_invoice)
      @charges = all_charges.reject { |charge| subscription_invoice_ids.include?(charge.invoice) }
    else
      @charges = []
      @subscriptions = []
    end
  end


  private

  def verify_payment_user
    unless current_user.id.to_s == params[:user_id]
      redirect_to users_dash_boards_path
    end
  end
end
