class Admins::ChargePlansController < Admins::Base

  def new
    @charge_plan = ChargePlan.new
  end

  def confirm
    @charge_plan = ChargePlan.new(charge_plan_params)
    @charge_plan.admin_id = current_admin.id
    render :new if @charge_plan.invalid?
  end

  def back
    @charge_plan = ChargePlan.new(charge_plan_params)
    @charge_plan.admin_id = current_admin.id
    render :new
  end

  def create
    @charge_plan = ChargePlan.new(charge_plan_params)
    @charge_plan.admin_id = current_admin.id
    @charge_plan.save
    render :complete
  end

  def complete
  end

  def show
    @charge_plan = ChargePlan.find(params[:id])
  end

  def edit
    @charge_plan = ChargePlan.find(params[:id])
  end

  def update
    @charge_plan = ChargePlan.find(params[:id])
    @charge_plan.update(charge_plan_params)
    render action: :show
  end

  private

    def charge_plan_params
      params.require(:charge_plan).permit(:admin_id, :price, :quantity, :amount, :charge_type)
    end

end
