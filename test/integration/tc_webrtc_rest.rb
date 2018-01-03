#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require 'rest-client'
require 'json'
require '../common/test_constants'
require '../common/beef_test'

class TC_WebRTCRest < Test::Unit::TestCase

  class << self

    # Login to API before performing any tests - and fetch config too
    def startup
      json = {:username => BEEF_USER, :password => BEEF_PASSWD}.to_json
      @@headers = {:content_type => :json, :accept => :json}

      response = RestClient.post("#{RESTAPI_ADMIN}/login",
                                 json,
                                 @@headers)

      result = JSON.parse(response.body)
      @@token = result['token']

      $root_dir = '../../'
      $:.unshift($root_dir)

      require 'core/loader'

      BeEF::Core::Configuration.new(File.join($root_dir, 'config.yaml'))
      BeEF::Core::Configuration.instance.load_extensions_config

      @@config = BeEF::Core::Configuration.instance

      @@activated = @@config.get('beef.extension.webrtc.enable') || false

      @@victim1 = BeefTest.new_victim
      @@victim2 = BeefTest.new_victim
      
      # puts "WebRTC Tests beginning"
      sleep 8.0

      # Fetch last online browsers' ids
      rest_response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {
        :token => @@token}}
      result = JSON.parse(rest_response.body)
      browsers = result["hooked-browsers"]["online"]
      browsers.each_with_index do |elem, index|
        if index == browsers.length - 1
            @@victim2id = browsers["#{index}"]["id"].to_s
        end
        if index == browsers.length - 2
            @@victim1id = browsers["#{index}"]["id"].to_s
        end
      end

    end

    def shutdown
      $root_dir = nil
      @@victim1.driver.browser.close
      @@victim2.driver.browser.close
    end

  end

  def test_1_webrtc_check_for_two_hooked_browsers
    return unless @@activated

    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {
        :token => @@token}}
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    browsers = result["hooked-browsers"]["online"]
    assert_not_nil browsers
    assert_operator browsers.length, :>=, 2
  end

  def test_2_webrtc_establishing_p2p
    return unless @@activated

    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.post("#{RESTAPI_WEBRTC}/go?token=#{@@token}",
        {:from => @@victim1id, :to => @@victim2id, :verbose => "true"}.to_json,
        @@headers)
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert_equal true, result["success"]

    sleep 30.0

    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get "#{RESTAPI_LOGS}", {:params => {
        :token => @@token}}
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)

    loghitcount = 0
    result["logs"].reverse.each {|l|
      # Using free-space matching mode /x below to wrap regex.
      # therefore need to escape spaces I want to check, hence the \
      regex = Regexp.new(/Browser:(#{@@victim1id}|#{@@victim2id})\ received\ 
                         message\ from\ Browser:(#{@@victim1id}|#{@@victim2id})
                         :\ ICE\ Status:\ connected/x)
      loghitcount += 1 if (not regex.match(l["event"]).nil?) and
                          (l["type"].to_s.eql?("WebRTC"))
    }
    assert_equal 2, loghitcount
  end

  def test_3_webrtc_send_msg # assumes test 2 has run
    return unless @@activated

    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.post("#{RESTAPI_WEBRTC}/msg?token=#{@@token}",
        {:from => @@victim1id, :to => @@victim2id,
         :message => "RTC test message"}.to_json,
        @@headers)
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert_equal true, result["success"]

    sleep 10.0

    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get "#{RESTAPI_LOGS}", {:params => {
        :token => @@token}}
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)

    assert_block do
      result["logs"].reverse.each {|l|
        # Using free-space matching mode /x below to wrap regex.
        # therefore need to escape spaces I want to check, hence the \
        regex = Regexp.new(/Browser:(#{@@victim1id}|#{@@victim2id})\ received\ 
                           message\ from\ Browser:
                           (#{@@victim1id}|#{@@victim2id})
                           :\ RTC\ test\ message/x)
        return true if (not regex.match(l["event"]).nil?) and
                            (l["type"].to_s.eql?("WebRTC"))
      }
    end
  end

  def test_4_webrtc_stealthmode # assumes test 2 has run
    return unless @@activated

    # Test our two browsers are still online
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {
        :token => @@token}}
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    online = result["hooked-browsers"]["online"]
    assert_block do
      online.each {|hb|
        return true if hb[1]["id"].eql?(@@victim1id)
      }
    end
    assert_block do
      online.each {|hb|
        return true if hb[1]["id"].eql?(@@victim2id)
      }
    end
      

    # Command one of the browsers to go stealth
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.post("#{RESTAPI_WEBRTC}/msg?token=#{@@token}",
        {:from => @@victim1id, :to => @@victim2id,
         :message => "!gostealth"}.to_json,
        @@headers)
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert_equal true, result["success"]

    sleep 40.0 #Wait until that browser is offline.

    # Test that the browser is now offline
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {
        :token => @@token}}
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    offline = result["hooked-browsers"]["offline"]
    assert_block do
      offline.each {|hb|
        return true if hb[1]["id"].eql?(@@victim2id)
      }
    end

    # Test that we can bring it back online (which implies comms are still ok)
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.post("#{RESTAPI_WEBRTC}/msg?token=#{@@token}",
        {:from => @@victim1id, :to => @@victim2id,
         :message => "!endstealth"}.to_json,
        @@headers)
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    assert_equal true, result["success"]

    sleep 10.0 # Wait until browser comes back

    # Test that the browser is now online
    rest_response = nil
    assert_nothing_raised do
      rest_response = RestClient.get "#{RESTAPI_HOOKS}", {:params => {
        :token => @@token}}
    end
    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    online = result["hooked-browsers"]["online"]
    assert_block do
      online.each {|hb|
        return true if hb[1]["id"].eql?(@@victim2id)
      }
    end

  end

  def test_5_webrtc_execcmd # assumes test 2 has run
    return unless @@activated

    #

  end

  private

  # Standard assertions for verifying response from RESTful API
  def check_rest_response(response)
    assert_not_nil(response.body)
    assert_equal(200, response.code)
  end

end
