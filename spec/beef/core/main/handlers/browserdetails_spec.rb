RSpec.describe BeEF::Core::Handlers::BrowserDetails do
  let(:config) { BeEF::Core::Configuration.instance }
  let(:session_id) { 'test_session_123' }
  let(:mock_request) do
    double('Request',
           ip: '127.0.0.1',
           referer: 'http://example.com',
           env: { 'HTTP_USER_AGENT' => 'Mozilla/5.0' })
  end
  let(:data) do
    {
      'beefhook' => session_id,
      'request' => mock_request,
      'results' => {
        'browser.name' => 'FF',
        'browser.version' => '91.0',
        'browser.window.hostname' => 'example.com',
        'browser.window.hostport' => '80'
      }
    }
  end

  before do
    allow(config).to receive(:get).and_call_original
    allow(config).to receive(:get).with('beef.dns_hostname_lookup').and_return(false)
    allow(config).to receive(:get).with('beef.extension.network.enable').and_return(false)
    allow(config).to receive(:get).with('beef.http.websocket.enable').and_return(false)
    allow(BeEF::Filters).to receive(:is_valid_hook_session_id?).and_return(true)
    allow(BeEF::Core::Models::HookedBrowser).to receive(:where).and_return([])
    allow(BeEF::Core::Logger.instance).to receive(:register)
    allow(BeEF::Core::GeoIp.instance).to receive(:enabled?).and_return(false)
    # Stub NetworkHost if it exists, otherwise stub the constant
    if defined?(BeEF::Core::Models::NetworkHost)
      allow(BeEF::Core::Models::NetworkHost).to receive(:create)
    else
      stub_const('BeEF::Core::Models::NetworkHost', double('NetworkHost', create: nil))
    end
    allow(BeEF::Core::AutorunEngine::Engine.instance).to receive(:find_and_run_all_matching_rules_for_zombie)
  end

  describe '#initialize' do
    it 'initializes with data and calls setup' do
      expect_any_instance_of(described_class).to receive(:setup)
      described_class.new(data)
    end
  end

  describe '#err_msg' do
    let(:handler) do
      instance = described_class.allocate
      instance.instance_variable_set(:@data, data)
      instance
    end

    it 'calls print_error with prefixed message' do
      expect(handler).to receive(:print_error).with('[Browser Details] test error')
      handler.err_msg('test error')
    end
  end

  describe '#get_param' do
    let(:handler) do
      # Create handler but prevent full setup execution
      instance = described_class.allocate
      instance.instance_variable_set(:@data, data)
      instance
    end

    it 'returns value when key exists in hash' do
      result = handler.get_param(data['results'], 'browser.name')
      expect(result).to eq('FF')
    end

    it 'returns nil when key does not exist' do
      result = handler.get_param(data['results'], 'nonexistent')
      expect(result).to be_nil
    end

    it 'returns nil when query is not a hash' do
      result = handler.get_param('not a hash', 'key')
      expect(result).to be_nil
    end

    it 'converts value to string' do
      result = handler.get_param({ 'key' => 123 }, 'key')
      expect(result).to eq('123')
    end
  end

  describe '#setup' do
    it 'validates session id' do
      invalid_data = data.dup
      invalid_data['beefhook'] = 'invalid'
      allow(BeEF::Filters).to receive(:is_valid_hook_session_id?).with('invalid').and_return(false)
      expect { described_class.new(invalid_data) }.not_to raise_error
    end

    it 'skips setup if browser already registered' do
      existing_browser = double('HookedBrowser', session: session_id)
      allow(BeEF::Core::Models::HookedBrowser).to receive(:where).and_return([existing_browser])
      expect(BeEF::Core::Models::HookedBrowser).not_to receive(:new)
      described_class.new(data)
    end

    it 'creates new hooked browser when not registered' do
      allow(BeEF::Core::Models::HookedBrowser).to receive(:where).and_return([])
      allow(BeEF::Filters).to receive(:is_valid_browsername?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_browserversion?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_ip?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_browserstring?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_cookies?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_osname?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_hwname?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_date_stamp?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_pagetitle?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_url?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_pagereferrer?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_hostname?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_port?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_browser_plugins?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_system_platform?).and_return(true)
      allow(BeEF::Filters).to receive(:nums_only?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_yes_no?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_memory?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_gpu?).and_return(true)
      allow(BeEF::Filters).to receive(:is_valid_cpu?).and_return(true)
      allow(BeEF::Filters).to receive(:alphanums_only?).and_return(true)
      allow(BeEF::Core::Models::BrowserDetails).to receive(:set)
      allow(BeEF::Core::Constants::Browsers).to receive(:friendly_name).and_return('Firefox')
      zombie = double('HookedBrowser', id: 1, ip: '127.0.0.1')
      allow(zombie).to receive(:firstseen=)
      allow(zombie).to receive(:domain=)
      allow(zombie).to receive(:port=)
      allow(zombie).to receive(:httpheaders=)
      allow(zombie).to receive(:httpheaders).and_return('{}')
      allow(zombie).to receive(:save!)
      # Mock JSON.parse for proxy detection
      allow(JSON).to receive(:parse).with('{}').and_return({})
      allow(BeEF::Core::Models::HookedBrowser).to receive(:new).and_return(zombie)
      described_class.new(data)
      expect(BeEF::Core::Models::HookedBrowser).to have_received(:new).with(ip: '127.0.0.1', session: session_id)
    end
  end
end
