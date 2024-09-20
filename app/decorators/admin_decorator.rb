class AdminDecorator < ApplicationDecorator
  delegate_all

  def already_charged_plan(current_admin)
    charge_plan_id = current_admin.charge_plan.try(:id)
    if charge_plan_id
      "<li style=\"padding-left:3px\">#{h.link_to '料金設定', h.admins_charge_plan_path(charge_plan_id)}</li>".html_safe
    else
      "<li style=\"padding-left:3px\">#{h.link_to '料金設定の新規作成', h.new_admins_charge_plan_path }</li>".html_safe
    end
  end

end
