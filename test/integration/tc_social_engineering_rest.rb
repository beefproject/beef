#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require 'rest-client'
require 'json'
require '../common/test_constants'

# @todo RESTful API for the social engineering extension lacks some serious test coverage.
class TC_SocialEngineeringRest < Test::Unit::TestCase

  class << self

    # Login to API before performing any tests
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
    end

    def shutdown
      $root_dir = nil
    end

  end

  # Tests DNS spoofing of cloned webpages
  def test_1_dns_spoof
    url = 'http://beefproject.com'
    mount = '/beefproject'
    dns_spoof = true

    json = {:url => url, :mount => mount, :dns_spoof => dns_spoof}.to_json

    domain = url.gsub(%r{^https?://}, '')

    response = RestClient.post("#{RESTAPI_SENG}/clone_page?token=#{@@token}",
                               json,
                               @@headers)

    check_response(response)

    # Send DNS request to server to verify that a new rule was added
    dns_address = @@config.get('beef.extension.dns.address')
    dns_port = @@config.get('beef.extension.dns.port')
    dig_output = IO.popen(["dig", "@#{dns_address}", "-p", "#{dns_port}", "-t",
                          "A", "+short", "#{domain}"], 'r+').read.strip!

    foundmatch = false

    # Iterate local IPs (excluding loopbacks) to find a match to the 'dig'
    # output
    assert_block do
        Socket.ip_address_list.each { |i|
            if !(i.ipv4_loopback? || i.ipv6_loopback?)
                return true if i.ip_address.to_s.eql?(dig_output.to_s)
            end
        }
    end

    # assert(foundmatch)
  end

  private

  # Assertions for verifying a response from the RESTful API
  def check_response(response)
    assert_not_nil(response.body)
    assert_equal(200, response.code)

    result = JSON.parse(response.body)

    assert(result['success'])
    assert(result['mount'])
  end

end
