#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe BeEF::Core::NetworkStack::Handlers::AssetHandler do
  let(:handler) { described_class.instance }

  before do
    @mock_server = double('server', mount: true, unmount: true, remap: true)
    allow(BeEF::Core::Server).to receive(:instance).and_return(@mock_server)
    # Reset singleton state
    handler.instance_variable_set(:@allocations, {})
    handler.instance_variable_set(:@sockets, {})
    handler.instance_variable_set(:@http_server, @mock_server)
  end

  describe '#initialize' do
    it 'initializes with empty allocations and sockets' do
      expect(handler.allocations).to eq({})
      expect(handler.root_dir).to be_a(String)
    end
  end

  describe '#build_url' do
    it 'returns path when path is provided' do
      expect(handler.build_url('/test', nil)).to eq('/test')
    end

    it 'appends extension when provided' do
      expect(handler.build_url('/test', 'js')).to eq('/test.js')
    end

    it 'generates random URL when path is nil' do
      url = handler.build_url(nil, nil)
      expect(url).to start_with('/')
      expect(url.length).to be > 1
    end

    it 'generates random URL with extension when path is nil' do
      url = handler.build_url(nil, 'js')
      expect(url).to end_with('.js')
      expect(url).to start_with('/')
    end
  end

  describe '#check' do
    it 'returns false when URL is not allocated' do
      expect(handler.check('/nonexistent')).to be false
    end

    it 'returns true when count is -1 (unlimited)' do
      handler.instance_variable_set(:@allocations, { '/test' => { 'count' => -1 } })
      expect(handler.check('/test')).to be true
    end

    it 'decrements count and returns true when count > 0' do
      handler.instance_variable_set(:@allocations, { '/test' => { 'count' => 2 } })
      expect(handler.check('/test')).to be true
      expect(handler.allocations['/test']['count']).to eq(1)
    end

    it 'unbinds when count reaches 0' do
      handler.instance_variable_set(:@allocations, { '/test' => { 'count' => 1 } })
      expect(handler).to receive(:unbind).with('/test')
      handler.check('/test')
    end

    it 'returns false when count is 0' do
      handler.instance_variable_set(:@allocations, { '/test' => { 'count' => 0 } })
      expect(handler.check('/test')).to be false
    end
  end

  describe '#bind_redirect' do
    it 'binds redirector to URL' do
      expect(@mock_server).to receive(:mount)
      expect(@mock_server).to receive(:remap)
      url = handler.bind_redirect('http://example.com', '/redirect')
      expect(url).to eq('/redirect')
      expect(handler.allocations['/redirect']).to eq({ 'target' => 'http://example.com' })
    end

    it 'generates random URL when path is nil' do
      expect(@mock_server).to receive(:mount)
      expect(@mock_server).to receive(:remap)
      url = handler.bind_redirect('http://example.com')
      expect(url).to start_with('/')
      expect(handler.allocations[url]).not_to be_nil
    end
  end

  describe '#bind_raw' do
    it 'binds raw HTTP response to URL' do
      expect(@mock_server).to receive(:mount)
      expect(@mock_server).to receive(:remap)
      url = handler.bind_raw('200', { 'Content-Type' => 'text/html' }, '<html></html>', '/raw')
      expect(url).to eq('/raw')
      expect(handler.allocations['/raw']).to eq({})
    end
  end

  describe '#bind' do
    let(:test_file) { '/spec/support/assets/test.txt' }
    let(:test_file_path) { File.join(handler.root_dir, test_file) }

    before do
      FileUtils.mkdir_p(File.dirname(test_file_path))
      File.write(test_file_path, 'test content')
    end

    after do
      FileUtils.rm_f(test_file_path)
    end

    it 'binds file to URL when file exists' do
      expect(@mock_server).to receive(:mount)
      expect(@mock_server).to receive(:remap)
      url = handler.bind(test_file, '/test')
      expect(url).to eq('/test')
      expect(handler.allocations['/test']['file']).to include(test_file)
    end

    it 'returns nil when file does not exist' do
      expect(@mock_server).not_to receive(:mount)
      result = handler.bind('/nonexistent/file.txt', '/test')
      expect(result).to be_nil
    end

    it 'uses text/plain content type when extension is nil' do
      expect(@mock_server).to receive(:mount) do |_url, handler_obj|
        expect(handler_obj.instance_variable_get(:@header)['Content-Type']).to eq('text/plain')
      end
      expect(@mock_server).to receive(:remap)
      handler.bind(test_file, '/test', nil)
    end
  end

  describe '#unbind' do
    it 'removes allocation and unmounts URL' do
      handler.instance_variable_set(:@allocations, { '/test' => {} })
      expect(@mock_server).to receive(:unmount).with('/test')
      expect(@mock_server).to receive(:remap)
      handler.unbind('/test')
      expect(handler.allocations).not_to have_key('/test')
    end
  end
end
