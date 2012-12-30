#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require 'rubygems'
require 'curb'

class TC_DynamicReconstruction < Test::Unit::TestCase

  @@port = 20000 + rand(10000)

  def setup
    $root_dir="../../"
    $:.unshift File.join( %w{ ../../ } )
    require 'core/loader'
    require 'core/main/network_stack/handlers/dynamicreconstruction.rb'

    @@port += 1 # cycle through ports because the tcp teardown process is too slow
    @port = @@port

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

    @pid = fork do
      @server.start!
    end
  end

  def teardown
    Process.kill("INT",@pid)
    $root_dir = nil
  end

  # the server doesn't offer a mutex or callback
  def wait_for_server
    max_waits = 3
    sleep_length = 0.1

    count = 0
    while (count < max_waits)
      break if @server.running?
      count += 1
      sleep sleep_length
    end
  end

  def test_delete
    wait_for_server
    response = Curl::Easy.http_delete("http://127.0.0.1:" + @port.to_s + "/test")
    assert_equal 404, response.response_code
  end

  def test_put
    wait_for_server
    response = Curl::Easy.http_put("http://127.0.0.1:" + @port.to_s + "/test", nil)
    assert_equal 404, response.response_code
  end

  def test_head
    wait_for_server
    response = Curl::Easy.http_head("http://127.0.0.1:" + @port.to_s + "/test")
    assert_equal 404, response.response_code
  end

  def test_no_params
    wait_for_server
    response = Curl::Easy.http_get("http://127.0.0.1:" + @port.to_s + "/test")
    assert_equal 404, response.response_code
  end

  def test_zero_values
    wait_for_server
    response = Curl::Easy.http_get("http://127.0.0.1:" + @port.to_s + "/test?bh=0&sid=0&pid=0&pc=0&d=0")
    assert_equal 200, response.response_code
    assert_equal "", response.body_str
  end

  def test_one_values
    wait_for_server
    response = Curl::Easy.http_get("http://127.0.0.1:" + @port.to_s + "/test?bh=1&sid=1&pid=1&pc=1&d=1")
    assert_equal 200, response.response_code
    assert_equal "", response.body_str
  end

  def test_neg_one_values
    wait_for_server
    response = Curl::Easy.http_get("http://127.0.0.1:" + @port.to_s + "/test?bh=-1&sid=-1&pid=-1&pc=-1&d=-1")
    assert_equal 200, response.response_code
    assert_equal "", response.body_str
  end

end
