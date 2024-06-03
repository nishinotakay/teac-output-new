class UserDecorator < ApplicationDecorator
  delegate_all

  def charge_type_flag
    subscriptions = ChargePlan.find_by(charge_type: "定額決済")
    single_charge = ChargePlan.find_by(charge_type: "一括払い")

    links = []
    links << "<li>#{h.link_to('定額決済', h.new_users_subscription_path)}</li>" if subscriptions.present?
    links << "<li>#{h.link_to('一括払い', h.new_users_checkout_path)}</li>" if single_charge.present?
    links << "<li>#{h.link_to('支払履歴', h.users_user_payments_path(object))}</li>" if subscriptions.present? || single_charge.present?
  
    links.join.html_safe
  end
end
