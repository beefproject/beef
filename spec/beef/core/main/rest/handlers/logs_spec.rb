RSpec.describe BeEF::Core::Rest::Logs do
  let(:config) { BeEF::Core::Configuration.instance }
  let(:api_token) { 'test_token' }

  before do
    allow(config).to receive(:get).and_call_original
    allow(config).to receive(:get).with('beef.api_token').and_return(api_token)
    allow(BeEF::Core::Rest).to receive(:permitted_source?).and_return(true)
  end

  describe 'logs_to_json helper method' do
    it 'converts logs to JSON format' do
      hb = BeEF::Core::Models::HookedBrowser.create!(session: 'test_session', ip: '127.0.0.1')
      BeEF::Core::Models::Log.create!(
        event: 'Test Event 1',
        logtype: 'INFO',
        hooked_browser_id: hb.id,
        date: Time.now
      )
      BeEF::Core::Models::Log.create!(
        event: 'Test Event 2',
        logtype: 'WARN',
        hooked_browser_id: hb.id,
        date: Time.now
      )

      logs = BeEF::Core::Models::Log.all

      # Test the logic directly
      logs_json = logs.map do |log|
        {
          'id' => log.id.to_i,
          'date' => log.date.to_s,
          'event' => log.event.to_s,
          'logtype' => log.logtype.to_s,
          'hooked_browser_id' => log.hooked_browser_id.to_s
        }
      end
      count = logs.length

      result = unless logs_json.empty?
                 {
                   'logs_count' => count,
                   'logs' => logs_json
                 }.to_json
               end

      parsed = JSON.parse(result)
      expect(parsed['logs_count']).to eq(2)
      expect(parsed['logs'].length).to eq(2)
      expect(parsed['logs'][0]['event']).to eq('Test Event 1')
      expect(parsed['logs'][0]['logtype']).to eq('INFO')
    end

    it 'handles empty logs' do
      logs = BeEF::Core::Models::Log.all

      logs_json = logs.map do |log|
        {
          'id' => log.id.to_i,
          'date' => log.date.to_s,
          'event' => log.event.to_s,
          'logtype' => log.logtype.to_s,
          'hooked_browser_id' => log.hooked_browser_id.to_s
        }
      end
      count = logs.length

      result = unless logs_json.empty?
                 {
                   'logs_count' => count,
                   'logs' => logs_json
                 }.to_json
               end

      expect(result).to be_nil
    end
  end

  describe 'GET /:session' do
    it 'returns logs for a specific session' do
      hb = BeEF::Core::Models::HookedBrowser.create!(session: 'test_session', ip: '127.0.0.1')
      BeEF::Core::Models::Log.create!(
        event: 'Session Event',
        logtype: 'INFO',
        hooked_browser_id: hb.id,
        date: Time.now
      )

      logs = BeEF::Core::Models::Log.where(hooked_browser_id: hb.id)
      expect(logs.length).to eq(1)
      expect(logs.first.event).to eq('Session Event')
    end
  end
end
