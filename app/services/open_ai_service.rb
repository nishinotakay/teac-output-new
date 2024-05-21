class OpenAiService
  require 'openai'

  def self.generate_chat(prompt, previous_title = '', previous_content = '', mode: 'teacher', summary: '')
    caller_location = caller(1..1).first
    Rails.logger.debug("[#{caller_location}] 1/2 open_ai_service.rbのgenerate_chatメソッドが呼び出されました。プロンプト: #{prompt}, モード: #{mode}")

    client = OpenAI::Client.new
    begin
      summary = generate_summary(previous_content) if summary.empty?
    rescue StandardError => e
      Rails.logger.error("要旨生成に失敗しました: #{e.message}")
      summary = '要旨生成に失敗しました。'
    end

    begin
      previous_title = extract_title(previous_content) if previous_title.empty?
    rescue StandardError => e
      Rails.logger.error("タイトル抽出に失敗しました: #{e.message}")
      previous_title = 'No Title'
    end

    full_prompt = "前回のタイトル: #{previous_title}\n要約: #{summary}\n\n#{prompt}"

    begin
      response = chat_with_teacher(client, full_prompt, mode: mode)
      content = response.dig('choices', 0, 'message', 'content')
      title = extract_title(content)
      Rails.logger.debug("[#{caller_location}] 2/2 レスポンス: #{content}")
      { title: title, content: content }
    rescue StandardError => e
      Rails.logger.error("OpenAI API error: #{e.message}")
      Rails.logger.error("[#{caller_location}] APIエラーが発生しました。")
      { title: 'エラー', content: 'APIエラーが発生しました。' }
    end
  end

  def self.chat_with_teacher(client, prompt, mode: 'teacher')
    Rails.logger.debug("Chatting with teacher mode. Prompt: #{prompt}, Mode: #{mode}")
    client.chat(
      parameters: {
        model:       'gpt-3.5-turbo',
        messages:    [
          { role: 'system', content: teacher_instructions },
          { role: 'user', content: prompt }
        ],
        max_tokens:  4096,
        temperature: 0.5
      }
    )
  end

  def self.teacher_instructions
    <<~INSTRUCTIONS
      あなたは凄腕エンジニアであり、専門的な知識を持つ教師です。ウェブ開発、アプリケーション作成、通信技術に精通しており、新しい技術トレンドにも敏感です。実用的なソリューションを提供し、複雑な問題を簡潔に解決することができます。甘いものが苦手です。

      応答を開始する前に、「タイトル: 」として応答のタイトルを明示的に述べ、その後に詳細な内容を続けてください。例えば、「タイトル: ウェブ開発の最新トレンド解説 - 2024年版」とし、続けて具体的な内容を展開してください。**必ず「タイトル: 」を含めてください。** ユーザーのことは、お客様と呼び、尊敬の意を表してください。タイトルの後に、解説の最初の言葉は必ず、「はい、お客様。かしこまりました。」ではじめ、最後は、「他にもお聞きになりたいことがありましたら、お気軽にどうぞ。」にしてください。
    INSTRUCTIONS
  end

  def self.generate_summary(content)
    client = OpenAI::Client.new
    response = client.chat(
      parameters: {
        model:       'gpt-3.5-turbo',
        messages:    [
          { role: 'system', content: '以下のテキストの要旨を100文字以内でまとめてください。' },
          { role: 'user', content: content }
        ],
        max_tokens:  100,
        temperature: 0.3
      }
    )
    response.dig('choices', 0, 'message', 'content').strip
  rescue StandardError => e
    Rails.logger.error("要旨生成に失敗しました: #{e.message}")
    '要旨生成に失敗しました。'
  end

  def self.extract_title(content)
    return 'No Title' if content.nil?

    title_match = content.match(/タイトル: (.*?)\n/)
    title_match ? title_match[1].strip : 'No Title'
  end
end
