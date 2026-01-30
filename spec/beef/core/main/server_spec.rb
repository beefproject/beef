#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::Server do
  let(:config) { BeEF::Core::Configuration.instance }
  let(:server) { described_class.instance }

  before do
    # Reset singleton instance for each test
    described_class.instance_variable_set(:@singleton__instance__, nil)
  end

  describe '#initialize' do
    it 'initializes with configuration' do
      expect(server.configuration).to eq(config)
    end

    it 'sets root_dir' do
      expect(server.root_dir).to be_a(String)
      expect(server.root_dir).to be_a(Pathname).or(be_a(String))
    end

    it 'initializes empty mounts hash' do
      expect(server.mounts).to eq({})
    end

    it 'initializes empty command_urls hash' do
      expect(server.command_urls).to eq({})
    end

    it 'creates a semaphore' do
      expect(server.semaphore).to be_a(Mutex)
    end
  end

  describe '#to_h' do
    it 'returns a hash with server information' do
      result = server.to_h
      expect(result).to be_a(Hash)
      expect(result).to have_key('beef_url')
      expect(result).to have_key('beef_root_dir')
      expect(result).to have_key('beef_host')
      expect(result).to have_key('beef_port')
    end

    it 'includes hook file path' do
      # The to_h method calls config.get, so we need to allow it
      allow(config).to receive(:get).and_call_original
      allow(config).to receive(:get).with('beef.http.hook_file').and_return('/hook.js')
      result = server.to_h
      expect(result['beef_hook']).to eq('/hook.js')
    end
  end

  describe '#mount' do
    it 'mounts a handler without arguments' do
      handler_class = Class.new
      server.mount('/test', handler_class)
      expect(server.mounts['/test']).to eq(handler_class)
    end

    it 'mounts a handler with arguments' do
      handler_class = Class.new
      server.mount('/test', handler_class, 'arg1')
      expect(server.mounts['/test']).to eq([handler_class, 'arg1'])
    end

    it 'raises TypeError for non-string URL' do
      handler_class = Class.new
      expect { server.mount(123, handler_class) }.to raise_error(TypeError, /"url" needs to be a string/)
    end

    it 'overwrites existing mount' do
      handler1 = Class.new
      handler2 = Class.new
      server.mount('/test', handler1)
      server.mount('/test', handler2)
      expect(server.mounts['/test']).to eq(handler2)
    end
  end

  describe '#unmount' do
    it 'removes a mounted handler' do
      handler_class = Class.new
      server.mount('/test', handler_class)
      server.unmount('/test')
      expect(server.mounts).not_to have_key('/test')
    end

    it 'raises TypeError for non-string URL' do
      expect { server.unmount(123) }.to raise_error(TypeError, /"url" needs to be a string/)
    end

    it 'does nothing if URL is not mounted' do
      expect { server.unmount('/nonexistent') }.not_to raise_error
      expect(server.mounts).not_to have_key('/nonexistent')
    end
  end

  describe '#remap' do
    it 'calls remap on rack_app with mounts' do
      handler_class = Class.new
      server.mount('/test', handler_class)
      mock_rack_app = double('Rack::URLMap')
      server.instance_variable_set(:@rack_app, mock_rack_app)
      expect(mock_rack_app).to receive(:remap).with(server.mounts)
      server.remap
    end
  end
end
