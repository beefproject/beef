#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe 'BeEF Redirector' do

  before(:all) do
    @__ar_config_snapshot = SpecActiveRecordConnection.snapshot
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


    # ***** IMPORTANT: close any and all AR/OTR connections before forking *****
    disconnect_all_active_record!

    @pid = fork do
      @server.start!
    end
    # wait for server to start
    sleep 0.8
  end

  after(:all) do
    Process.kill("INT",@pid)
    SpecActiveRecordConnection.restore!(@__ar_config_snapshot)
  end

  it 'redirects' do
    response = Curl::Easy.http_get("http://127.0.0.1:#{@port}/test/")
    expect(response.response_code).to eql(302)
    expect(response.body_str).to eql("302 found")
    expect(response.header_str).to match(/^location:\s*http:\/\/www\.beefproject\.com\r?$/i)
  end

end
