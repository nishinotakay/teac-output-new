class UserDecorator < ApplicationDecorator
  delegate_all

  def charge_type_flag
    subscriptions = ChargePlan.find_by(charge_type: "定額決済")
    single_charge = ChargePlan.find_by(charge_type: "一括払い")

    if subscriptions.present? || single_charge.present?
      if subscriptions.present?
        "<li>#{h.link_to '定額決済', h.new_users_subscription_path}</li>".html_safe
      elsif single_charge.present?
        "<li>#{h.link_to '一括払い', h.new_users_checkout_path}</li>".html_safe
      end
    end

  end

end
