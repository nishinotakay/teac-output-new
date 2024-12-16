class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, opts = {})
    if record.tenant_id.present?
      opts[:template_path] = 'devise/mailer'
      if record.is_a?(Admin)
        generated_url = tenant_admin_admin_confirmation_url(tenant_id: record.tenant_id, confirmation_token: token)
      else
        generated_url = tenant_user_user_confirmation_url(tenant_id: record.tenant_id, confirmation_token: token)
        Rails.logger.debug "Generated URL: #{generated_url}"
      end
    else
      opts[:template_path] = 'users/mailer'
      generated_url = user_confirmation_url(confirmation_token: token)
    end

    Rails.logger.debug "Generated URL: #{generated_url}"

    super
  end  
end
