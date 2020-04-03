require 'rest-client'
require 'core/main/network_stack/websocket/websocket'
require 'em-websocket-client'

RSpec.describe 'BeEF Extension WebSockets' do

  before(:all) do
    @config = BeEF::Core::Configuration.instance
    @cert_key = @config.get('beef.http.https.key')
    @cert = @config.get('beef.http.https.cert')
    @port = @config.get('beef.http.websocket.port')
    @secure_port = @config.get('beef.http.websocket.secure_port')
  end

  it 'Create Websocket Server' do
        ws = BeEF::Core::Websocket::Websocket.instance
	server= ws.start_websocket_server(:host => '127.0.0.1',
					  :port => @port ,
					  :secure => false)
	expect(server).to be_a_kind_of(Thread)
  end

  it 'Create Websocket Secure Server' do
        ws = BeEF::Core::Websocket::Websocket.instance
	server= ws.start_websocket_server(:host => '127.0.0.1', 
					  :port => @secure_port , 
					  :secure => true,
					  :tls_options => {
					     :cert_chain_file  => @cert,
					     :private_key_file => @cert_key
					  })
	expect(server).to be_a_kind_of(Thread)
  end

end
