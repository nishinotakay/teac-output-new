class CustomDeviseMailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers

  def confirmation_instructions(record, token, opts = {})

    if record.tenant_id.present?
      opts[:template_path] = 'devise/mailer'
    else
      opts[:template_path] = 'users/mailer'
    end
  
    opts[:url_options] ||= {}
    opts[:url_options][:tenant_id] = record.tenant_id if record.tenant_id.present?

    generated_url = tenant_user_user_confirmation_url(tenant_id: record.tenant_id, confirmation_token: token)
    Rails.logger.debug "Generated URL: #{generated_url}"

    super
  end
end
