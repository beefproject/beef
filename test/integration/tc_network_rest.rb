#
# Copyright (c) 2006-2015 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require 'rest-client'
require 'json'
require '../common/test_constants'

class TC_NetworkRest < Test::Unit::TestCase

  class << self

    def startup
      $root_dir = '../../'
      $:.unshift($root_dir)

      # login and get api token
      json = {:username => BEEF_USER, :password => BEEF_PASSWD}.to_json
      @@headers = {:content_type => :json, :accept => :json}

      response = RestClient.post("#{RESTAPI_ADMIN}/login",
                                 json,
                                 @@headers)

      result = JSON.parse(response.body)
      @@token = result['token']

      # create hooked browser and get session id
      BeefTest.new_victim
      sleep 5.0
      response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {:token => @@token}}
      result = JSON.parse(response.body)
      @@hb_session = result["hooked-browsers"]["online"]["0"]["session"]

      # Retrieve Port Scanner module command ID
      response = RestClient.get "#{RESTAPI_MODULES}", {:params => {:token => @@token}}
      result = JSON.parse(response.body)
      result.each do |mod|
        if mod[1]['class'] == 'Port_scanner'
          @@mod_port_scanner = mod[1]["id"]
          break
        end
      end

      # Execute the Port Scanner module on the BeEF host to populate NetworkService object
      # Port Scanner module works only for Chrome and Firefox
      response = RestClient.post "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_port_scanner}?token=#{@@token}",
                               { 'ipHost' => "#{ATTACK_DOMAIN}",
                                 'ports' => 3000,
                                 'closetimeout' => 1100,
                                 'opentimeout' => 2500,
                                 'delay' => 600,
                                 'debug' => false}.to_json,
                               :content_type => :json,
                               :accept => :json
      result = JSON.parse(response.body)
      success = result['success']
      @@cmd_id = result['command_id']
      sleep 15.0
    end

    def shutdown
      $root_dir = nil
    end

  end

  # Ensure the Port Scanner module identified the BeEF host
  def test_port_scanner_results
    rest_response = RestClient.get "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_port_scanner}/#{@@cmd_id}?token=#{@@token}"
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    raise "Port Scanner module failed to identify any open ports" unless result.to_s =~ /Port 3000 is OPEN/
  end

  # Tests GET /api/network/hosts handler
  def test_get_all_hosts
    rest_response = RestClient.get("#{RESTAPI_NETWORK}/hosts?token=#{@@token}")
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert(result['count'])
    assert(result['hosts'])
    assert_not_equal(0, result['count'])
  end

  # Tests GET /api/network/hosts/:sessionid handler with valid input
  def test_get_hosts_valid_session
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get("#{RESTAPI_NETWORK}/hosts/#{@@hb_session}", :params => {:token => @@token})
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert(result['count'])
    assert(result['hosts'])
    assert_not_equal(0, result['count'])

    result['hosts'].each do |host|
      assert_equal(@@hb_session, host['hooked_browser_id'])
    end
  end

  # Tests GET /api/network/hosts/:sessionid handler with invalid input
  def test_get_hosts_invalid_session
    session_id = 'z'
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get("#{RESTAPI_NETWORK}/hosts/#{session_id}", :params => {:token => @@token})
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert(result['count'])
    assert_equal(0, result['count'])
  end

  # Tests GET /api/network/host/:id handler with valid input
  def test_get_host_valid_id
    id = 1
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get("#{RESTAPI_NETWORK}/host/#{id}", :params => {:token => @@token})
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert_equal(1, result.length)
    assert_equal('localhost', result.first['hostname'])
  end

  # Tests GET /api/network/host/:id handler with invalid input
  def test_get_hosts_invalid_id
    id = 'z'
    assert_raise RestClient::ResourceNotFound do
      RestClient.get("#{RESTAPI_NETWORK}/host/#{id}", :params => {:token => @@token})
    end
  end

  # Tests GET /api/network/services handler
  def test_get_all_services
    rest_response = RestClient.get("#{RESTAPI_NETWORK}/services?token=#{@@token}",
                                    @@headers)
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert(result['count'])
    assert(result['services'])
    assert_not_equal(0, result['count'])
  end

  # Tests GET /api/network/services/:sessionid handler with valid input
  def test_get_services_valid_session
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get("#{RESTAPI_NETWORK}/services/#{@@hb_session}", :params => {:token => @@token})
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert(result['count'])
    assert(result['services'])
    assert_not_equal(0, result['count'])

    result['services'].each do |service|
      assert_equal(@@hb_session, service['hooked_browser_id'])
    end
  end

  # Tests GET /api/network/services/:sessionid handler with invalid input
  def test_get_services_invalid_session
    session_id = 'z'
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get("#{RESTAPI_NETWORK}/services/#{session_id}", :params => {:token => @@token})
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert(result['count'])
    assert_equal(0, result['count'])
  end

  # Tests GET /api/network/service/:id handler with valid input
  def test_get_service_valid_id
    id = 1
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get("#{RESTAPI_NETWORK}/service/#{id}", :params => {:token => @@token})
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert_equal(1, result.length)
    assert_not_nil(result.first['type'])
  end

  # Tests GET /api/network/service/:id handler with invalid input
  def test_get_services_invalid_id
    id = 'z'
    assert_raise RestClient::ResourceNotFound do
      RestClient.get("#{RESTAPI_NETWORK}/service/#{id}", :params => {:token => @@token})
    end
  end

  private

  # Standard assertions for verifying response from RESTful API
  def check_rest_response(response)
    assert_not_nil(response.body)
    assert_equal(200, response.code)
  end

end
