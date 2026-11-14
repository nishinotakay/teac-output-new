require 'rails_helper'

RSpec.describe GoogleArticleSearch do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('GOOGLE_SEARCH_PROJECT_ID').and_return('test-project')
    allow(ENV).to receive(:[]).with('GOOGLE_SEARCH_ENGINE_ID').and_return('test-engine')
    allow(ENV).to receive(:[]).with('GOOGLE_SEARCH_ACCESS_TOKEN').and_return('test-token')
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('GOOGLE_SEARCH_LOCATION', 'global').and_return('global')
  end

  it '未設定の場合は通信せず設定エラーにする' do
    allow(ENV).to receive(:[]).with('GOOGLE_SEARCH_PROJECT_ID').and_return(nil)
    expect(Net::HTTP).not_to receive(:start)
    expect { described_class.new.call('Rubyの記事') }.to raise_error(GoogleArticleSearch::NotConfigured)
  end

  it '自然言語の条件抽出を有効にして検索し、表示用の項目を返す' do
    response = Net::HTTPOK.new('1.1', '200', 'OK')
    allow(response).to receive(:body).and_return({ results: [{ document: { id: '42', structData: { title: 'Ruby入門', author: '田中' } } }], totalSize: 1 }.to_json)
    client = double('http')
    expect(client).to receive(:request) do |request|
      expect(request['Authorization']).to eq('Bearer test-token')
      payload = JSON.parse(request.body)
      expect(payload['query']).to eq('田中さんのRubyの記事')
      expect(payload.dig('naturalLanguageQueryUnderstandingSpec', 'filterExtractionCondition')).to eq('ENABLED')
      response
    end
    allow(Net::HTTP).to receive(:start).and_yield(client)
    result = described_class.new.call('田中さんのRubyの記事')
    expect(result[:articles]).to eq([{ id: '42', title: 'Ruby入門', author: '田中' }])
  end

  it 'Googleの認証エラーを、秘密情報を含まない検索エラーにする' do
    client = double('http', request: Net::HTTPUnauthorized.new('1.1', '401', 'Unauthorized'))
    allow(Net::HTTP).to receive(:start).and_yield(client)
    expect { described_class.new.call('Ruby') }.to raise_error(GoogleArticleSearch::SearchFailed)
  end
end
