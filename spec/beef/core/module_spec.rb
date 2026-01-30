#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Module do
  let(:config) { BeEF::Core::Configuration.instance }

  describe '.is_present' do
    it 'returns true when module exists in configuration' do
      allow(config).to receive(:get).with('beef.module').and_return({ 'test_module' => {} })
      expect(described_class.is_present('test_module')).to be true
    end

    it 'returns false when module does not exist' do
      allow(config).to receive(:get).with('beef.module').and_return({})
      expect(described_class.is_present('nonexistent')).to be false
    end
  end

  describe '.is_enabled' do
    it 'returns true when module is present and enabled' do
      allow(config).to receive(:get).with('beef.module').and_return({ 'test_module' => {} })
      allow(config).to receive(:get).with('beef.module.test_module.enable').and_return(true)
      expect(described_class.is_enabled('test_module')).to be true
    end

    it 'returns false when module is not present' do
      allow(config).to receive(:get).with('beef.module').and_return({})
      expect(described_class.is_enabled('nonexistent')).to be false
    end

    it 'returns false when module is disabled' do
      allow(config).to receive(:get).with('beef.module').and_return({ 'test_module' => {} })
      allow(config).to receive(:get).with('beef.module.test_module.enable').and_return(false)
      expect(described_class.is_enabled('test_module')).to be false
    end
  end

  describe '.is_loaded' do
    it 'returns true when module is enabled and loaded' do
      allow(config).to receive(:get).with('beef.module').and_return({ 'test_module' => {} })
      allow(config).to receive(:get).with('beef.module.test_module.enable').and_return(true)
      allow(config).to receive(:get).with('beef.module.test_module.loaded').and_return(true)
      expect(described_class.is_loaded('test_module')).to be true
    end

    it 'returns false when module is not loaded' do
      allow(config).to receive(:get).with('beef.module').and_return({ 'test_module' => {} })
      allow(config).to receive(:get).with('beef.module.test_module.enable').and_return(true)
      allow(config).to receive(:get).with('beef.module.test_module.loaded').and_return(false)
      expect(described_class.is_loaded('test_module')).to be false
    end
  end

  describe '.get_key_by_database_id' do
    it 'returns module key for matching database id' do
      modules = {
        'module1' => { 'db' => { 'id' => 1 } },
        'module2' => { 'db' => { 'id' => 2 } }
      }
      allow(config).to receive(:get).with('beef.module').and_return(modules)
      expect(described_class.get_key_by_database_id(2)).to eq('module2')
    end

    it 'returns nil when no module matches' do
      allow(config).to receive(:get).with('beef.module').and_return({})
      expect(described_class.get_key_by_database_id(999)).to be_nil
    end
  end

  describe '.get_key_by_class' do
    it 'returns module key for matching class' do
      modules = {
        'module1' => { 'class' => 'TestClass1' },
        'module2' => { 'class' => 'TestClass2' }
      }
      allow(config).to receive(:get).with('beef.module').and_return(modules)
      expect(described_class.get_key_by_class('TestClass2')).to eq('module2')
    end
  end

  describe '.exists?' do
    it 'returns true when class exists' do
      test_class = Class.new
      BeEF::Core::Command.const_set(:Testmodule, test_class)
      expect(described_class.exists?('testmodule')).to be true
      BeEF::Core::Command.send(:remove_const, :Testmodule)
    end

    it 'returns false when class does not exist' do
      expect(described_class.exists?('NonexistentClass')).to be false
    end
  end

  describe '.match_target_browser' do
    it 'returns browser constant for valid browser string' do
      result = described_class.match_target_browser('FF')
      expect(result).to eq(BeEF::Core::Constants::Browsers::FF)
    end

    it 'returns false for invalid browser string' do
      expect(described_class.match_target_browser('InvalidBrowser')).to be false
    end

    it 'returns false for non-string input' do
      expect(described_class.match_target_browser(123)).to be false
    end
  end

  describe '.match_target_os' do
    it 'returns OS constant for valid OS string' do
      result = described_class.match_target_os('Linux')
      expect(result).to eq(BeEF::Core::Constants::Os::OS_LINUX_UA_STR)
    end

    it 'returns false for invalid OS string' do
      expect(described_class.match_target_os('InvalidOS')).to be false
    end

    it 'returns false for non-string input' do
      expect(described_class.match_target_os(123)).to be false
    end
  end

  describe '.match_target_browser_spec' do
    it 'returns hash with max_ver and min_ver' do
      spec = { 'max_ver' => 10, 'min_ver' => 5 }
      result = described_class.match_target_browser_spec(spec)
      expect(result['max_ver']).to eq(10)
      expect(result['min_ver']).to eq(5)
    end

    it 'handles latest as max_ver' do
      spec = { 'max_ver' => 'latest' }
      result = described_class.match_target_browser_spec(spec)
      expect(result['max_ver']).to eq('latest')
    end

    it 'returns empty hash for non-hash input' do
      expect(described_class.match_target_browser_spec('invalid')).to eq({})
    end

    it 'includes OS when specified' do
      spec = { 'max_ver' => 10, 'os' => 'Linux' }
      result = described_class.match_target_browser_spec(spec)
      expect(result['os']).to eq(BeEF::Core::Constants::Os::OS_LINUX_UA_STR)
    end
  end

  describe '.merge_options' do
    it 'returns nil when module is not present' do
      allow(config).to receive(:get).with('beef.module').and_return({})
      expect(described_class.merge_options('nonexistent', [])).to be_nil
    end

    it 'merges default options with custom options' do
      allow(config).to receive(:get).with('beef.module').and_return({ 'test_module' => {} })
      allow(described_class).to receive(:is_present).and_return(true)
      allow(described_class).to receive(:check_hard_load).and_return(true)
      allow(described_class).to receive(:get_options).and_return(
        [
          { 'name' => 'option1', 'value' => 'default1' },
          { 'name' => 'option2', 'value' => 'default2' }
        ]
      )
      custom_opts = [{ 'name' => 'option1', 'value' => 'custom1' }]
      result = described_class.merge_options('test_module', custom_opts)

      expect(result.length).to eq(2)
      expect(result.find { |o| o['name'] == 'option1' }['value']).to eq('custom1')
      expect(result.find { |o| o['name'] == 'option2' }['value']).to eq('default2')
    end
  end

  describe '.check_hard_load' do
    it 'returns true when module is already loaded' do
      allow(described_class).to receive(:is_loaded).and_return(true)
      expect(described_class.check_hard_load('test_module')).to be true
    end

    it 'calls hard_load when module is not loaded' do
      allow(described_class).to receive(:is_loaded).and_return(false)
      expect(described_class).to receive(:hard_load).with('test_module')
      described_class.check_hard_load('test_module')
    end
  end
end
