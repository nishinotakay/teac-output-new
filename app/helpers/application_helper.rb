# frozen_string_literal: true

module ApplicationHelper
  def page_body_id(params)
    "#{params[:controller].gsub(/\//, '-')}-#{params[:action]}"
  end

  # 危険性があるhtmlタグを除去、改行を<br>に置換、空白を半角スペースに置換、URLをリンク化。
  def format_and_linkify_text(str)
    sanitized_str = sanitize(str)
    sanitized_str.gsub!(/\r\n|\n|\r/, '<br>')
    sanitized_str.gsub!(/ /, '&nbsp;')
    linked_str = Rinku.auto_link(sanitized_str, :all, 'target="_blank"')
    linked_str.html_safe
  end
end
