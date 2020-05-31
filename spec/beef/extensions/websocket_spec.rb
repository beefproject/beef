require 'rest-client'
require 'core/main/network_stack/websocket/websocket'
require 'websocket-client-simple'

RSpec.describe 'BeEF Extension WebSockets' do
  before(:all) do
    @config = BeEF::Core::Configuration.instance
    @cert_key = @config.get('beef.http.https.key')
    @cert = @config.get('beef.http.https.cert')
    @port = @config.get('beef.http.websocket.port')
    @secure_port = @config.get('beef.http.websocket.secure_port')
    @config.set('beef.http.websocket.secure', false)
    @ws = BeEF::Core::Websocket::Websocket.instance
  end

  after(:all) do
    @config.set('beef.http.websocket.secure', true)
  end

  it 'confirms that a websocket server has been started' do
	  expect(@ws).to be_a_kind_of(BeEF::Core::Websocket::Websocket)
  end

  it 'confirms that a secure websocket server has been started' do
    @config.set('beef.http.websocket.secure', true)
    wss = BeEF::Core::Websocket::Websocket.instance
    expect(wss).to be_a_kind_of(BeEF::Core::Websocket::Websocket)
  end

  it 'confirms that a websocket client can connect to the BeEF Websocket Server' do
    sleep(3)
    client = WebSocket::Client::Simple.connect "ws://127.0.0.1:#{@port}"
    sleep(1)
    expect(client).to be_a_kind_of(WebSocket::Client::Simple::Client)
    expect(client.open?).to be true
    client.close
  end
end
