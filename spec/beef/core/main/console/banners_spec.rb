#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

require 'spec_helper'

RSpec.describe BeEF::Core::Console::Banners do
  let(:config) { BeEF::Core::Configuration.instance }

  before do
    allow(described_class).to receive(:print_info)
    allow(described_class).to receive(:print_more)
  end

  describe '.print_welcome_msg' do
    it 'calls print_info with version from config' do
      allow(config).to receive(:get).with('beef.version').and_return('1.0.0')
      described_class.print_welcome_msg
      expect(described_class).to have_received(:print_info).with('Browser Exploitation Framework (BeEF) 1.0.0')
    end

    it 'calls print_more with project links' do
      allow(config).to receive(:get).with('beef.version').and_return('1.0.0')
      described_class.print_welcome_msg
      expect(described_class).to have_received(:print_more).with(a_string_including('@beefproject'))
      expect(described_class).to have_received(:print_more).with(a_string_including('beefproject.com'))
      expect(described_class).to have_received(:print_more).with(a_string_including('github.com/beefproject'))
    end

    it 'calls print_info with project creator' do
      allow(config).to receive(:get).with('beef.version').and_return('1.0.0')
      described_class.print_welcome_msg
      expect(described_class).to have_received(:print_info).with(a_string_including('Wade Alcorn'))
      expect(described_class).to have_received(:print_info).with(a_string_including('@WadeAlcorn'))
    end
  end

  describe '.print_network_interfaces_count' do
    it 'uses config local_host and sets interfaces when host is 0.0.0.0' do
      allow(config).to receive(:local_host).and_return('0.0.0.0')
      mock_addrs = [double('Addr', ip_address: '127.0.0.1', ipv4?: true), double('Addr', ip_address: '192.168.1.1', ipv4?: true)]
      allow(Socket).to receive(:ip_address_list).and_return(mock_addrs)
      described_class.print_network_interfaces_count
      expect(described_class.interfaces).to eq(['127.0.0.1', '192.168.1.1'])
      expect(described_class).to have_received(:print_info).with('2 network interfaces were detected.')
    end

    it 'sets single interface when host is not 0.0.0.0' do
      allow(config).to receive(:local_host).and_return('192.168.1.1')
      described_class.print_network_interfaces_count
      expect(described_class.interfaces).to eq(['192.168.1.1'])
      expect(described_class).to have_received(:print_info).with('1 network interfaces were detected.')
    end
  end

  describe '.print_loaded_extensions' do
    it 'calls print_info with count from Extensions.get_loaded' do
      allow(BeEF::Extensions).to receive(:get_loaded).and_return({ 'AdminUI' => { 'name' => 'Admin UI' }, 'DNS' => { 'name' => 'DNS' } })
      described_class.print_loaded_extensions
      expect(described_class).to have_received(:print_info).with('2 extensions enabled:')
      expect(described_class).to have_received(:print_more).with(a_string_including('Admin UI'))
      expect(described_class).to have_received(:print_more).with(a_string_including('DNS'))
    end

    it 'handles empty extensions' do
      allow(BeEF::Extensions).to receive(:get_loaded).and_return({})
      described_class.print_loaded_extensions
      expect(described_class).to have_received(:print_info).with('0 extensions enabled:')
    end
  end

  describe '.print_loaded_modules' do
    it 'calls print_info with count from Modules.get_enabled' do
      enabled = double('Relation', count: 42)
      allow(BeEF::Modules).to receive(:get_enabled).and_return(enabled)
      described_class.print_loaded_modules
      expect(described_class).to have_received(:print_info).with('42 modules enabled.')
    end
  end

  describe '.print_ascii_art' do
    it 'reads and puts file content when beef.ascii exists' do
      allow(File).to receive(:exist?).with('core/main/console/beef.ascii').and_return(true)
      io = StringIO.new("BEEF\nASCII\n")
      allow(File).to receive(:open).with('core/main/console/beef.ascii', 'r').and_yield(io)
      allow(described_class).to receive(:puts)
      described_class.print_ascii_art
      expect(described_class).to have_received(:puts).with("BEEF\n")
      expect(described_class).to have_received(:puts).with("ASCII\n")
    end

    it 'does nothing when beef.ascii does not exist' do
      allow(File).to receive(:exist?).with('core/main/console/beef.ascii').and_return(false)
      expect(File).not_to receive(:open)
      described_class.print_ascii_art
    end
  end

  describe '.print_network_interfaces_routes' do
    before do
      described_class.interfaces = ['127.0.0.1', '192.168.1.1']
    end

    it 'prints hook and UI URL for each interface when admin_ui enabled' do
      allow(config).to receive(:local_proto).and_return('http')
      allow(config).to receive(:hook_file_path).and_return('/hook.js')
      allow(config).to receive(:get).with('beef.extension.admin_ui.enable').and_return(true)
      allow(config).to receive(:get).with('beef.extension.admin_ui.base_path').and_return('/ui')
      allow(config).to receive(:local_port).and_return(3000)
      allow(config).to receive(:public_enabled?).and_return(false)

      described_class.print_network_interfaces_routes

      expect(described_class).to have_received(:print_info).with('running on network interface: 127.0.0.1')
      expect(described_class).to have_received(:print_info).with('running on network interface: 192.168.1.1')
      expect(described_class).to have_received(:print_more).with(a_string_matching(%r{Hook URL: http://127\.0\.0\.1:3000/hook\.js}))
      expect(described_class).to have_received(:print_more).at_least(:twice).with(a_string_matching(%r{UI URL:.*/ui/panel}))
    end

    it 'omits UI URL when admin_ui disabled' do
      allow(config).to receive(:local_proto).and_return('http')
      allow(config).to receive(:hook_file_path).and_return('/hook.js')
      allow(config).to receive(:get).with('beef.extension.admin_ui.enable').and_return(false)
      allow(config).to receive(:get).with('beef.extension.admin_ui.base_path').and_return('/ui')
      allow(config).to receive(:local_port).and_return(3000)
      allow(config).to receive(:public_enabled?).and_return(false)

      described_class.print_network_interfaces_routes

      expect(described_class).to have_received(:print_more).with("Hook URL: http://127.0.0.1:3000/hook.js\n")
      expect(described_class).to have_received(:print_more).with("Hook URL: http://192.168.1.1:3000/hook.js\n")
    end

    it 'prints public hook and UI when public_enabled?' do
      allow(config).to receive(:local_proto).and_return('http')
      allow(config).to receive(:hook_file_path).and_return('/hook.js')
      allow(config).to receive(:get).with('beef.extension.admin_ui.enable').and_return(true)
      allow(config).to receive(:get).with('beef.extension.admin_ui.base_path').and_return('/ui')
      allow(config).to receive(:local_port).and_return(3000)
      allow(config).to receive(:public_enabled?).and_return(true)
      allow(config).to receive(:hook_url).and_return('http://public.example.com/hook.js')
      allow(config).to receive(:beef_url_str).and_return('http://public.example.com')

      described_class.print_network_interfaces_routes

      expect(described_class).to have_received(:print_info).with('Public:')
      expect(described_class).to have_received(:print_more).with(a_string_including('http://public.example.com/hook.js'))
      expect(described_class).to have_received(:print_more).at_least(:once).with(a_string_including('/ui/panel'))
    end
  end

  describe '.print_websocket_servers' do
    it 'prints WebSocket server line with host, port and timer' do
      allow(config).to receive(:beef_host).and_return('0.0.0.0')
      allow(config).to receive(:get).with('beef.http.websocket.ws_poll_timeout').and_return(5)
      allow(config).to receive(:get).with('beef.http.websocket.port').and_return(61_985)
      allow(config).to receive(:get).with('beef.http.websocket.secure').and_return(false)

      described_class.print_websocket_servers

      expect(described_class).to have_received(:print_info).with('Starting WebSocket server ws://0.0.0.0:61985 [timer: 5]')
    end

    it 'prints WebSocketSecure server when secure enabled' do
      allow(config).to receive(:beef_host).and_return('0.0.0.0')
      allow(config).to receive(:get).with('beef.http.websocket.ws_poll_timeout').and_return(10)
      allow(config).to receive(:get).with('beef.http.websocket.port').and_return(61_985)
      allow(config).to receive(:get).with('beef.http.websocket.secure').and_return(true)
      allow(config).to receive(:get).with('beef.http.websocket.secure_port').and_return(61_986)

      described_class.print_websocket_servers

      expect(described_class).to have_received(:print_info).with('Starting WebSocket server ws://0.0.0.0:61985 [timer: 10]')
      expect(described_class).to have_received(:print_info).with(a_string_matching(/WebSocketSecure.*wss:.*61986.*timer: 10/))
    end
  end

  describe '.print_http_proxy' do
    it 'prints proxy address and port from config' do
      allow(config).to receive(:get).with('beef.extension.proxy.address').and_return('127.0.0.1')
      allow(config).to receive(:get).with('beef.extension.proxy.port').and_return(8080)

      described_class.print_http_proxy

      expect(described_class).to have_received(:print_info).with('HTTP Proxy: http://127.0.0.1:8080')
    end
  end

  describe '.print_dns' do
    it 'does not raise when DNS config is not set' do
      expect { described_class.print_dns }.not_to raise_error
    end
  end
end
