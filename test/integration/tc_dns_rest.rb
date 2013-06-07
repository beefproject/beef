#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require 'rest_client'
require 'json'
require '../common/test_constants'

class TC_DnsRest < Test::Unit::TestCase

  class << self

    def startup
      json = {:username => BEEF_USER, :password => BEEF_PASSWD}.to_json
      @@headers = {:content_type => :json, :accept => :json}

      response = RestClient.post("#{RESTAPI_ADMIN}/login",
                                 json,
                                 @@headers)

      result  = JSON.parse(response.body)
      @@token = result['token']
    end

  end

  def test_1_add_rule
    pattern = 'foo.bar'
    type = 'A'
    dns_response = ['1.2.3.4']

    json = {:pattern => pattern, :type => type, :response => dns_response}.to_json

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    json,
                                    @@headers)

    assert_not_nil(rest_response.body)
    assert_equal(200, rest_response.code)

    result = JSON.parse(rest_response.body)

    assert(result['success'])
    assert(result['id'])
  end

end
