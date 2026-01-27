RSpec.describe BeEF::Core::NetworkStack::RegisterHttpHandler do
  describe '.mount_handler' do
    let(:mock_server) { double('server', mount: true) }

    it 'mounts dynamic reconstruction handler' do
      expect(mock_server).to receive(:mount).with('/dh', anything)
      described_class.mount_handler(mock_server)
    end
  end
end
