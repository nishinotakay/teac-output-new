# config/initializers/openai.rb
require 'openai'

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_API_KEY') # APIキーを取得
  # オプショナルな設定、組織IDが必要な場合は以下の行のコメントを解除
  # config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID")
end
