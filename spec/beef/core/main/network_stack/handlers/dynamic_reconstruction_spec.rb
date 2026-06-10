#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

RSpec.describe 'BeEF Dynamic Reconsturction' do

  before(:all) do
    @__ar_config_snapshot = SpecActiveRecordConnection.snapshot
    @port = 2001
    config = {}
    config[:BindAddress] = '127.0.0.1'
    config[:Port] = @port.to_s
    @mounts = {}
    @mounts['/test'] = BeEF::Core::NetworkStack::Handlers::DynamicReconstruction.new
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
    sleep 1
  end

  after(:all) do
    Process.kill("INT",@pid)
    SpecActiveRecordConnection.restore!(@__ar_config_snapshot)
  end

  it 'delete' do
    response = Curl::Easy.http_delete("http://127.0.0.1:#{@port}/test")
    expect(response.response_code).to eql(404)
  end

  it 'put' do
    response = Curl::Easy.http_put("http://127.0.0.1:#{@port}/test", nil)
    expect(response.response_code).to eql(404)
  end

  it 'head' do
    response = Curl::Easy.http_head("http://127.0.0.1:#{@port}/test")
    expect(response.response_code).to eql(404)
  end

  context 'get' do

    it 'no params' do
      response = Curl::Easy.http_get("http://127.0.0.1:#{@port}/test")
      expect(response.response_code).to eql(404)
    end

    it 'zero values' do
      response = Curl::Easy.http_get("http://127.0.0.1:#{@port}/test?bh=0&sid=0&pid=0&pc=0&d=0")
      expect(response.response_code).to eql(200)
      expect(response.body_str).to be_empty
    end

    it 'one values' do
      response = Curl::Easy.http_get("http://127.0.0.1:#{@port}/test?bh=1&sid=1&pid=1&pc=1&d=1")
      expect(response.response_code).to eql(200)
      expect(response.body_str).to be_empty
    end

    it 'negative one values' do
      response = Curl::Easy.http_get("http://127.0.0.1:#{@port}/test?bh=-1&sid=-1&pid=-1&pc=-1&d=-1")
      expect(response.response_code).to eql(200)
      expect(response.body_str).to be_empty
    end

    # Fails gracefully
    it 'ascii values' do
      response = Curl::Easy.http_get("http://127.0.0.1:#{@port}/test?bh=z&sid=z&pid=z&pc=z&d=z")
      expect(response.response_code).to eql(200)
      expect(response.body_str).to be_empty
    end

    # Fails gracefully
    it 'array values' do
      response = Curl::Easy.http_get("http://127.0.0.1:#{@port}/test?bh[]=1&sid[]=1&pid[]=1&pc[]=1&d[]=1")
      expect(response.response_code).to eql(200)
      expect(response.body_str).to be_empty
    end

  end

end
