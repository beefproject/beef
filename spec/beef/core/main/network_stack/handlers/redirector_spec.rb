RSpec.describe 'BeEF Redirector' do

  before(:all) do
    @port = 2002
    config = {}
    config[:BindAddress] = '127.0.0.1'
    config[:Port] = @port.to_s
    @mounts = {}
    @mounts['/test'] = BeEF::Core::NetworkStack::Handlers::Redirector.new('http://www.beefproject.com')
    @rackApp = Rack::URLMap.new(@mounts)
    Thin::Logging.silent = true
    @server = Thin::Server.new('127.0.0.1', @port.to_s, @rackApp)
    trap("INT") { @server.stop }
    trap("TERM") { @server.stop }
    @pid = fork do
      @server.start!
    end
    # wait for server to start
    sleep 0.8
  end

  after(:all) do
    Process.kill("INT",@pid)
  end

  it 'redirects' do
    response = Curl::Easy.http_get("http://127.0.0.1:#{@port}/test/")
    expect(response.response_code).to eql(302)
    expect(response.body_str).to eql("302 found")
    expect(response.header_str).to match(/Location: http:\/\/www.beefproject\.com/)
  end

end
