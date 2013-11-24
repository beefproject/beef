#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require 'rest_client'
require 'json'
require '../common/test_constants'
require '../common/beef_test'

class TC_DebugModules < Test::Unit::TestCase

  @@token = nil
  @@hb_session = nil

  @@mod_debug_long_string = nil
  @@mod_debug_ascii_chars = nil
  @@mod_debug_test_network = nil

  # NOTE: Tests within the same test class are called in the order they are defined.
  # NOTE: However, test classes are run in alphabetical order by classname.
  # That's why we use the prefix x_N_y, with N being the order of execution.
  #

  # Test RESTful API authentication with default credentials, returns the API token to be used later.
  def test_1_restful_auth
    response = RestClient.post "#{RESTAPI_ADMIN}/login",
                               { 'username' => "#{BEEF_USER}",
                                 'password' => "#{BEEF_PASSWD}"}.to_json,
                               :content_type => :json,
                               :accept => :json
    assert_equal 200, response.code
    assert_not_nil response.body
    result = JSON.parse(response.body)
    success = result['success']
    @@token = result['token']
    assert(success)
  end

  # Test RESTful API hooks handler hooking a victim browser, and then retrieving his BeEF session
  def test_2_restful_hooks
    BeefTest.new_victim
    sleep 5.0
    response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {:token => @@token}}
    assert_equal 200, response.code
    assert_not_nil response.body
    result = JSON.parse(response.body)
    @@hb_session = result["hooked-browsers"]["online"]["0"]["session"]
    assert_not_nil @@hb_session
  end

  # Test RESTful API modules handler, retrieving the IDs of the 3 debug modules currently in the framework
  def test_3_restful_modules
    response = RestClient.get "#{RESTAPI_MODULES}", {:params => {:token => @@token}}
    assert_equal 200, response.code
    assert_not_nil response.body
    result = JSON.parse(response.body)
    result.each do |mod|
     case mod[1]["class"]
       when "Test_return_long_string"
         @@mod_debug_long_string = mod[1]["id"]
       when "Test_return_ascii_chars"
         @@mod_debug_ascii_chars = mod[1]["id"]
       when "Test_network_request"
         @@mod_debug_test_network = mod[1]["id"]
     end
    end
    assert_not_nil @@mod_debug_long_string
    assert_not_nil @@mod_debug_ascii_chars
    assert_not_nil @@mod_debug_test_network
  end
  #
  ## Test debug module "Test_return_long_string" using the RESTful API
  def test_return_long_string
    repeat_string = "BeEF"
    repeat_count = 20

    response = RestClient.post "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_debug_long_string}?token=#{@@token}",
                               { 'repeat_string' => repeat_string,
                                 'repeat'        => repeat_count}.to_json,
                               :content_type => :json,
                               :accept => :json
    assert_equal 200, response.code
    assert_not_nil response.body
    result = JSON.parse(response.body)
    success = result['success']
    assert success

    cmd_id = result['command_id']
    count = 0
    response = RestClient.get "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_debug_long_string}/#{cmd_id}?token=#{@@token}"

    #TODO if the response is empty, the body size is 2, basically an empty Hash.
    # don't know why empty?, nil and other checks are not working.
    while(response.body.size <= 2 && count < 10)
      response = RestClient.get "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_debug_long_string}/#{cmd_id}?token=#{@@token}"
      sleep 2
      count += 1
    end
    assert_equal 200, response.code
    assert_not_nil response.body
    result = JSON.parse(response.body)
    data = JSON.parse(result['0']['data'])['data']
    assert_not_nil data
    assert_equal data,(repeat_string * repeat_count)
  end
  #
  ## Test debug module "Test_return_ascii_chars" using the RESTful API
  def test_return_ascii_chars
    response = RestClient.post "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_debug_ascii_chars}?token=#{@@token}",
                               {}.to_json, # module does not expect any input
                               :content_type => :json,
                               :accept => :json
    assert_equal 200, response.code
    assert_not_nil response.body
    result = JSON.parse(response.body)
    success = result['success']
    assert success
    cmd_id = result['command_id']
    count = 0
    response = RestClient.get "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_debug_ascii_chars}/#{cmd_id}?token=#{@@token}"

    #TODO if the response is empty, the body size is 2, basically an empty Hash.
    # don't know why empty?, nil and other checks are not working.
    while(response.body.size <= 2 && count < 10)
       response = RestClient.get "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_debug_ascii_chars}/#{cmd_id}?token=#{@@token}"
       sleep 2
       count += 1
    end
    assert_equal 200, response.code
    assert_not_nil response.body
    result = JSON.parse(response.body)
    data = JSON.parse(result['0']['data'])['data']
    assert_not_nil data
    ascii_chars = ""
    (32..127).each do |i| ascii_chars << i.chr end
    assert_equal ascii_chars,data
  end

  # Test debug module "Test_network_request" using the RESTful API
  def test_return_network_request

    # Test same-domain request (response code and content of secret_page.html)
    response = RestClient.post "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_debug_test_network}?token=#{@@token}",
                                #override only a few parameters, the other ones will have default values from modules's module.rb definition
                               {"domain" => ATTACK_DOMAIN, "port" => "3000", "path" => "/demos/secret_page.html"}.to_json,
                               :content_type => :json,
                               :accept => :json
    assert_equal 200, response.code
    assert_not_nil response.body
    result = JSON.parse(response.body)
    success = result['success']
    assert success

    cmd_id = result['command_id']
    count = 0
    response = RestClient.get "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_debug_test_network}/#{cmd_id}?token=#{@@token}"

    #TODO if the response is empty, the body size is 2, basically an empty Hash.
    # don't know why empty?, nil and other checks are not working.
    while(response.body.size <= 2 && count < 10)
      response = RestClient.get "#{RESTAPI_MODULES}/#{@@hb_session}/#{@@mod_debug_test_network}/#{cmd_id}?token=#{@@token}"
      sleep 2
      count += 1
    end
    assert_equal 200, response.code
    assert_not_nil response.body
    result = JSON.parse(response.body)
    data = JSON.parse(result['0']['data'])['data']
    assert_not_nil data
    assert_equal 200, JSON.parse(data)["status_code"]
    assert JSON.parse(data)["port_status"].include?("open")

  end
end