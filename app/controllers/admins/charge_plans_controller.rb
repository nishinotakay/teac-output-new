class Admins::ChargePlansController < Admins::Base
  before_action :check_double_charge, only: %i[new]
  before_action :set_charge_plan, only: %i[confirm back create]
  before_action :find_charge_plan, only: %i[show edit update destroy]
  before_action :check_charge_plan_owner, only: %i[show edit]

  def new
    @charge_plan = ChargePlan.new
  end

  def confirm
    @charge_plan.admin_id = current_admin.id
    render :new if @charge_plan.invalid?
  end

  def back
    @charge_plan.admin_id = current_admin.id
    render :new
  end

  def create
    @charge_plan.admin_id = current_admin.id
      if @charge_plan.charge_type == "定額決済"
        create_stripe_plan
      end
      if @charge_plan.save
        render :complete
      else
        render :confrim
      end
  end

  def complete
  end

  def show
  end

  def edit
  end

  def update
    if @charge_plan.update(charge_plan_params)
      if @charge_plan.charge_type == "定額決済"
        create_stripe_plan
      end
      render action: :show
    else
      render :edit
    end
  end

  def destroy
    if @charge_plan.destroy
      redirect_to admins_dash_boards_path
    else
      redirect_to admins_charge_plan_path
    end
  end

  private

    def set_charge_plan
      @charge_plan = ChargePlan.new(charge_plan_params)
    end

    def find_charge_plan
      @charge_plan = ChargePlan.find(params[:id])
    end

    def charge_plan_params
      params.require(:charge_plan).permit(:admin_id, :price, :quantity, :amount, :charge_type)
    end

    def check_double_charge   
      charge_plan = current_admin.charge_plan
      if charge_plan.present?
        redirect_to admins_charge_plan_path(charge_plan)
      end
    end

    def check_charge_plan_owner
      charge_plan = current_admin.charge_plan
      if charge_plan.present?
        @charge_plan = ChargePlan.find_by(id: current_admin.charge_plan.id)
          if current_admin.id != @charge_plan.admin_id
            redirect_to admins_dash_boards_path
          end
      end
    end

    def create_stripe_plan
      admin_id = current_admin.id
      product = Stripe::Product.create(
        name: '受講料',
        type: 'service',
        metadata: {admin_id: admin_id}
      )

      plan = Stripe::Plan.create(
        product: product.id,
        interval: "month",
        currency: "jpy",
        amount: @charge_plan.amount,
        metadata: {admin_id: admin_id}
      )

      @charge_plan.update(stripe_plan_id: plan.id)
    end

end
