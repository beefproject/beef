#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Extension do
  let(:config) { BeEF::Core::Configuration.instance }

  describe '.is_present' do
    it 'returns true when extension exists in configuration' do
      allow(config).to receive(:get).with('beef.extension').and_return({ 'test_ext' => {} })
      expect(described_class.is_present('test_ext')).to be true
    end

    it 'returns false when extension does not exist' do
      allow(config).to receive(:get).with('beef.extension').and_return({})
      expect(described_class.is_present('nonexistent')).to be false
    end

    it 'converts extension key to string' do
      allow(config).to receive(:get).with('beef.extension').and_return({ 'test_ext' => {} })
      expect(described_class.is_present(:test_ext)).to be true
    end
  end

  describe '.is_enabled' do
    it 'returns true when extension is present and enabled' do
      allow(config).to receive(:get).with('beef.extension').and_return({ 'test_ext' => {} })
      allow(config).to receive(:get).with('beef.extension.test_ext.enable').and_return(true)
      expect(described_class.is_enabled('test_ext')).to be true
    end

    it 'returns false when extension is not present' do
      allow(config).to receive(:get).with('beef.extension').and_return({})
      expect(described_class.is_enabled('nonexistent')).to be false
    end

    it 'returns false when extension is disabled' do
      allow(config).to receive(:get).with('beef.extension').and_return({ 'test_ext' => {} })
      allow(config).to receive(:get).with('beef.extension.test_ext.enable').and_return(false)
      expect(described_class.is_enabled('test_ext')).to be false
    end
  end

  describe '.is_loaded' do
    it 'returns true when extension is enabled and loaded' do
      allow(config).to receive(:get).with('beef.extension').and_return({ 'test_ext' => {} })
      allow(config).to receive(:get).with('beef.extension.test_ext.enable').and_return(true)
      allow(config).to receive(:get).with('beef.extension.test_ext.loaded').and_return(true)
      expect(described_class.is_loaded('test_ext')).to be true
    end

    it 'returns false when extension is not enabled' do
      allow(config).to receive(:get).with('beef.extension').and_return({ 'test_ext' => {} })
      allow(config).to receive(:get).with('beef.extension.test_ext.enable').and_return(false)
      expect(described_class.is_loaded('test_ext')).to be false
    end

    it 'returns false when extension is not loaded' do
      allow(config).to receive(:get).with('beef.extension').and_return({ 'test_ext' => {} })
      allow(config).to receive(:get).with('beef.extension.test_ext.enable').and_return(true)
      allow(config).to receive(:get).with('beef.extension.test_ext.loaded').and_return(false)
      expect(described_class.is_loaded('test_ext')).to be false
    end
  end

  describe '.load' do
    it 'returns true when extension file exists' do
      ext_path = "#{$root_dir}/extensions/test_ext/extension.rb"
      allow(File).to receive(:exist?).with(ext_path).and_return(true)
      allow(config).to receive(:set).with('beef.extension.test_ext.loaded', true).and_return(true)
      # Stub require on the module itself since it's called directly
      allow(described_class).to receive(:require).with(ext_path)
      expect(described_class.load('test_ext')).to be true
    end

    it 'returns false when extension file does not exist' do
      ext_path = "#{$root_dir}/extensions/test_ext/extension.rb"
      allow(File).to receive(:exist?).with(ext_path).and_return(false)
      expect(described_class.load('test_ext')).to be false
    end

    it 'sets loaded flag to true when successfully loaded' do
      ext_path = "#{$root_dir}/extensions/test_ext/extension.rb"
      allow(File).to receive(:exist?).with(ext_path).and_return(true)
      allow(described_class).to receive(:require).with(ext_path)
      expect(config).to receive(:set).with('beef.extension.test_ext.loaded', true).and_return(true)
      described_class.load('test_ext')
    end

    it 'handles errors during loading gracefully' do
      ext_path = "#{$root_dir}/extensions/test_ext/extension.rb"
      allow(File).to receive(:exist?).with(ext_path).and_return(true)
      allow(described_class).to receive(:require).with(ext_path).and_raise(StandardError.new('Load error'))
      # The rescue block calls print_more which may return a value, so just verify it doesn't raise
      expect { described_class.load('test_ext') }.not_to raise_error
    end
  end
end
