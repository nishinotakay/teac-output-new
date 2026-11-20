require 'net/http'
require 'json'

class GoogleArticleSearch
  class NotConfigured < StandardError; end
  class SearchFailed < StandardError; end

  def call(query)
    project = ENV['GOOGLE_SEARCH_PROJECT_ID'].to_s
    engine = ENV['GOOGLE_SEARCH_ENGINE_ID'].to_s
    token = ENV['GOOGLE_SEARCH_ACCESS_TOKEN'].to_s
    location = ENV.fetch('GOOGLE_SEARCH_LOCATION', 'global')
    unless [project, engine, token].all? { |value| !value.empty? }
      raise NotConfigured, 'Google Cloudの検索アプリが未設定です。管理者による接続設定が必要です。'
    end
    unless [project, engine].all? { |value| value.match?(/\A[a-zA-Z0-9_-]+\z/) } && %w[global us eu].include?(location)
      raise NotConfigured, 'Google Cloudの検索設定を確認してください。'
    end

    host = location == 'global' ? 'discoveryengine.googleapis.com' : "#{location}-discoveryengine.googleapis.com"
    uri = URI("https://#{host}/v1/projects/#{project}/locations/#{location}/collections/default_collection/engines/#{engine}/servingConfigs/default_search:search")
    request = Net::HTTP::Post.new(uri)
    request['Authorization'] = "Bearer #{token}"
    request['Content-Type'] = 'application/json'
    request.body = JSON.generate(query: query, pageSize: 20,
      naturalLanguageQueryUnderstandingSpec: { filterExtractionCondition: 'ENABLED' })
    response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 20) { |http| http.request(request) }
    raise SearchFailed, 'Google Cloudで検索できませんでした。接続設定や認証期限を確認してください。' unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    results = Array(data['results']).map do |result|
      document = result.fetch('document', {})
      fields = document.fetch('structData', {})
      { id: document['id'].to_s, title: fields.fetch('title', 'タイトルなし').to_s, author: fields.fetch('author', '').to_s }
    end
    { articles: results, total_count: data.fetch('totalSize', results.length),
      extracted_filters: data.dig('naturalLanguageQueryUnderstandingInfo', 'extractedFilters').to_s }
  rescue JSON::ParserError, IOError, SystemCallError, Timeout::Error, OpenSSL::SSL::SSLError
    raise SearchFailed, '検索サービスへの接続に失敗しました。時間をおいて再度お試しください。'
  end
end
