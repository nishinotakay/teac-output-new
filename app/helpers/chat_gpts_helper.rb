module ChatGptsHelper
  def extract_title_and_content(response)
    return ['', ''] if response.nil?

    title_match = response.match(/タイトル: (.*?)\n/)
    if title_match
      title = title_match[1]
      content = response.sub(title_match[0], '')
    else
      title = ''
      content = response
    end

    [title, content]
  end

  def split_questions_and_answers(content)
    content.scan(/質問：(.*?)\n回答：(.*?)(?=\n質問：|\z)/m)
  end
end
