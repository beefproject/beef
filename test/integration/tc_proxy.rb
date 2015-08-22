#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require 'rest-client'
require 'json'
require '../common/test_constants'
require '../common/beef_test'

class TC_Proxy < Test::Unit::TestCase

  class << self

    def startup
      $root_dir = '../../'
      $:.unshift($root_dir)

      # load proxy config
      require 'core/loader'
      BeEF::Core::Configuration.new(File.join($root_dir, 'config.yaml'))
      config = BeEF::Core::Configuration.instance
      config.load_extensions_config
      @@proxy_config = config.get('beef.extension.proxy')
      @@proxy = "#{@@proxy_config['address']}:#{@@proxy_config['port']}"

      # set up datamapper
      DataMapper.setup(:default, 'sqlite3::memory:')
      DataMapper.auto_migrate!

      # set headers for rest requests
      @@headers = { :content_type => :json, :accept => :json }

      # login and get api token
      json = {:username => BEEF_USER, :password => BEEF_PASSWD}.to_json
      response = RestClient.post("#{RESTAPI_ADMIN}/login", json, @@headers)
      result = JSON.parse(response.body)
      @@token = result['token']

      # create hooked browser and get session id
      @@victim = BeefTest.new_victim
      sleep 5.0
      response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {:token => @@token}}
      result = JSON.parse(response.body)
      @@hb_session = result["hooked-browsers"]["online"]["0"]["session"]

      # set proxy to use hooked browser
      result = set_target_zombie(@@hb_session)
    end

    def shutdown
      @@victim.driver.browser.close
      $root_dir = nil
    end

    # set zombie to be used as proxy
    def set_target_zombie(session_id)
      json = { :hb_id => session_id.to_s }.to_json
      response = RestClient.post("#{RESTAPI_PROXY}/setTargetZombie?token=#{@@token}", json, @@headers)
      result = JSON.parse(response.body)
      return result['success']
    end

  end

  def test_get_url_same_origin
    assert_nothing_raised do
      url = "http://#{VICTIM_DOMAIN}:3000/demos/secret_page.html"
      cmd = ['curl', '--connect-timeout', '30', '--max-time', '30', '-x', "#{@@proxy}", '-X', 'GET', '-isk', "#{url}"]
      res = IO.popen(cmd, 'r+').read
      assert_not_empty(res)
      assert_not_nil(res)
      raise "Proxy request failed - Unexpected response" unless res =~ /Secret Page/
    end
  end

  def test_post_url_same_origin
    assert_nothing_raised do
      url = "http://#{VICTIM_DOMAIN}:3000/demos/secret_page.html"
      cmd = ['curl', '--connect-timeout', '30', '--max-time', '30', '-x', "#{@@proxy}", '-X', 'POST', '-isk', "#{url}", '-d', 'beef=beef']
      res = IO.popen(cmd, 'r+').read
      assert_not_empty(res)
      assert_not_nil(res)
      raise "Proxy request failed - Unexpected response" unless res =~ /Secret Page/
    end
  end

  def test_get_url_cross_origin
    assert_nothing_raised do
      url = "http://#{ATTACK_DOMAIN}:3000/demos/plain.html"
      cmd = ['curl', '--connect-timeout', '30', '--max-time', '30', '-x', "#{@@proxy}", '-X', 'GET', '-isk', "#{url}"]
      res = IO.popen(cmd, 'r+').read
      assert_not_empty(res)
      assert_not_nil(res)
      raise "Proxy request failed - Unexpected response #{@@proxy}" unless res =~ /ERROR: Cross Domain Request/
    end
  end
end
