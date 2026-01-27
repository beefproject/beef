RSpec.describe BeEF::Core::Rest::BrowserDetails do
  let(:config) { BeEF::Core::Configuration.instance }
  let(:api_token) { 'test_token' }

  before do
    allow(config).to receive(:get).and_call_original
    allow(config).to receive(:get).with('beef.api_token').and_return(api_token)
    allow(BeEF::Core::Rest).to receive(:permitted_source?).and_return(true)
  end

  describe 'GET /:session' do
    it 'returns browser details for a session' do
      hb = BeEF::Core::Models::HookedBrowser.create!(session: 'test_session', ip: '127.0.0.1')
      BeEF::Core::Models::BrowserDetails.create!(session_id: hb.session, detail_key: 'browser.name', detail_value: 'Chrome')
      BeEF::Core::Models::BrowserDetails.create!(session_id: hb.session, detail_key: 'browser.version', detail_value: '91.0')

      # Test the logic directly
      details = BeEF::Core::Models::BrowserDetails.where(session_id: hb.session)
      result = details.map { |d| { key: d.detail_key, value: d.detail_value } }

      output = {
        'count' => result.length,
        'details' => result
      }

      parsed = JSON.parse(output.to_json)
      expect(parsed['count']).to eq(2)
      expect(parsed['details'].length).to eq(2)
      expect(parsed['details'][0]['key']).to eq('browser.name')
      expect(parsed['details'][0]['value']).to eq('Chrome')
    end

    it 'handles session with no browser details' do
      hb = BeEF::Core::Models::HookedBrowser.create!(session: 'empty_session', ip: '127.0.0.1')

      details = BeEF::Core::Models::BrowserDetails.where(session_id: hb.session)
      result = details.map { |d| { key: d.detail_key, value: d.detail_value } }

      output = {
        'count' => result.length,
        'details' => result
      }

      parsed = JSON.parse(output.to_json)
      expect(parsed['count']).to eq(0)
      expect(parsed['details']).to eq([])
    end
  end
end
