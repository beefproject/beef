#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::GeoIp do
  let(:config) { BeEF::Core::Configuration.instance }
  let(:geoip) { described_class.instance }

  # Mock MaxMind module if not available
  before do
    unless defined?(MaxMind)
      stub_const('MaxMind', Module.new)
      stub_const('MaxMind::DB', Class.new)
    end
    # MODE_MEMORY is actually :MODE_MEMORY (not :memory) - use actual value if available
    mode_memory = defined?(MaxMind::DB::MODE_MEMORY) ? MaxMind::DB::MODE_MEMORY : :MODE_MEMORY
    stub_const('MaxMind::DB::MODE_MEMORY', mode_memory) unless defined?(MaxMind::DB::MODE_MEMORY)
  end

  before do
    # Reset singleton instance for each test
    described_class.instance_variable_set(:@singleton__instance__, nil)
    # Allow config to receive other calls
    allow(config).to receive(:get).and_call_original
  end

  describe '#initialize' do
    it 'disables GeoIP when configuration is false' do
      allow(config).to receive(:get).with('beef.geoip.enable').and_return(false)
      expect(geoip.enabled?).to be false
    end

    it 'disables GeoIP when database file does not exist' do
      allow(config).to receive(:get).with('beef.geoip.enable').and_return(true)
      allow(config).to receive(:get).with('beef.geoip.database').and_return('/nonexistent/db.mmdb')
      allow(File).to receive(:exist?).with('/nonexistent/db.mmdb').and_return(false)
      expect(geoip.enabled?).to be false
    end

    it 'enables GeoIP when database file exists' do
      # Set up stub BEFORE singleton is created
      allow(config).to receive(:get).with('beef.geoip.enable').and_return(true)
      allow(config).to receive(:get).with('beef.geoip.database').and_return('/path/to/db.mmdb')
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/path/to/db.mmdb').and_return(true)
      mock_reader = double('MaxMind::DB')
      allow(mock_reader).to receive(:freeze)
      allow(MaxMind::DB).to receive(:new).with('/path/to/db.mmdb', { mode: MaxMind::DB::MODE_MEMORY }).and_return(mock_reader)
      # Reset singleton so it reinitializes with our stubs
      described_class.instance_variable_set(:@singleton__instance__, nil)
      expect(geoip.enabled?).to be true
    end

    it 'disables GeoIP on initialization error' do
      allow(config).to receive(:get).with('beef.geoip.enable').and_return(true)
      allow(config).to receive(:get).with('beef.geoip.database').and_return('/path/to/db.mmdb')
      allow(File).to receive(:exist?).with('/path/to/db.mmdb').and_return(true)
      allow(MaxMind::DB).to receive(:new).and_raise(StandardError.new('Database error'))
      expect(geoip.enabled?).to be false
    end
  end

  describe '#enabled?' do
    it 'returns false when GeoIP is disabled' do
      allow(config).to receive(:get).with('beef.geoip.enable').and_return(false)
      expect(geoip.enabled?).to be false
    end

    it 'returns true when GeoIP is enabled' do
      # Set up stub BEFORE singleton is created - singleton initializes when let(:geoip) is called
      allow(config).to receive(:get).with('beef.geoip.enable').and_return(true)
      allow(config).to receive(:get).with('beef.geoip.database').and_return('/path/to/db.mmdb')
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with('/path/to/db.mmdb').and_return(true)
      mock_reader = double('MaxMind::DB')
      allow(mock_reader).to receive(:freeze)
      # The actual call is: MaxMind::DB.new('/path/to/db.mmdb', mode: :MODE_MEMORY)
      allow(MaxMind::DB).to receive(:new).with('/path/to/db.mmdb', { mode: :MODE_MEMORY }).and_return(mock_reader)
      # Reset singleton so it reinitializes with our stubs
      described_class.instance_variable_set(:@singleton__instance__, nil)
      expect(geoip.enabled?).to be true
    end
  end

  describe '#lookup' do
    it 'raises TypeError for non-string IP' do
      allow(config).to receive(:get).with('beef.geoip.enable').and_return(false)
      expect { geoip.lookup(123) }.to raise_error(TypeError, /"ip" needs to be a string/)
    end

    it 'returns nil when GeoIP is disabled' do
      allow(config).to receive(:get).with('beef.geoip.enable').and_return(false)
      expect(geoip.lookup('192.168.1.1')).to be_nil
    end

    it 'returns lookup result when GeoIP is enabled' do
      allow(config).to receive(:get).with('beef.geoip.enable').and_return(true)
      allow(config).to receive(:get).with('beef.geoip.database').and_return('/path/to/db.mmdb')
      allow(File).to receive(:exist?).with('/path/to/db.mmdb').and_return(true)
      mock_reader = double('MaxMind::DB')
      allow(mock_reader).to receive(:freeze)
      allow(mock_reader).to receive(:get).with('192.168.1.1').and_return({ 'city' => 'Test City' })
      allow(MaxMind::DB).to receive(:new).with('/path/to/db.mmdb', anything).and_return(mock_reader)
      result = geoip.lookup('192.168.1.1')
      expect(result).to eq({ 'city' => 'Test City' })
    end
  end
end
