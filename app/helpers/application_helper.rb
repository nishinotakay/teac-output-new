# frozen_string_literal: true

module ApplicationHelper
  def page_body_id(params)
    "#{params[:controller].gsub(/\//, '-')}-#{params[:action]}"
  end
  
  def qiita_markdown(markdown) 
    processor = Qiita::Markdown::Processor.new(hostname: "example.com")
    processor.call(markdown)[:output].to_s.html_safe
  end
  
  def markdown(text)
    options = {
      no_styles:     true,
      with_toc_data: true,
      hard_wrap:     true,
    }
    extensions = {
      no_intra_emphasis:   true,
      tables:              true,
      fenced_code_blocks:  true,
      autolink:            true,
      lax_spacing:         true,
      space_after_headers: true,
    }

    renderer = CustomRenderHTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)
    markdown.render(text).html_safe
  end

  def toc(text)
    renderer = Redcarpet::Render::HTML_TOC.new(nesting_level: 3)
    markdown = Redcarpet::Markdown.new(renderer)
    markdown.render(text).html_safe
  end
  
end
