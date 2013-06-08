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

  def test_1_add_rule_good
    pattern = 'foo.bar'
    type = 'A'
    dns_response = ['1.2.3.4']

    json = {:pattern => pattern, :type => type, :response => dns_response}.to_json

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    json,
                                    @@headers)

    # Test that adding a new rule works properly
    check_response(rest_response)

    result = JSON.parse(rest_response.body)
    first_id = result['id']

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    json,
                                    @@headers)

    # Test that adding an existing rule returns its id
    check_response(rest_response)

    result = JSON.parse(rest_response.body)
    second_id = result['id']

    assert_equal(first_id, second_id)
  end

  def test_2_add_rule_bad
    pattern = ''
    type = 'A'
    dns_response = ['1.1.1.1']

    hash = {:pattern => pattern, :type => type, :response => dns_response}

    # Test that an empty "pattern" key returns 400
    assert_raise RestClient::BadRequest do
      rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                      hash.to_json,
                                      @@headers)
    end

    hash['pattern'] = 'foo.bar.baz'
    hash['type'] = ''

    # Test that an empty "type" key returns 400
    assert_raise RestClient::BadRequest do
      rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                      hash.to_json,
                                      @@headers)
    end

    hash['type'] = 'A'
    hash['response'] = []

    # Test that an empty "response" key returns 400
    assert_raise RestClient::BadRequest do
      rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                      hash.to_json,
                                      @@headers)
    end

    hash['response'] = 42

    # Test that a non-array "response" key returns 400
    assert_raise RestClient::BadRequest do
      rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                      hash.to_json,
                                      @@headers)
    end
  end

  # OPTIMIZE: Can this be refactored somehow?
  # TODO: Use BeEF::Core::Configuration to get address and port values.

  # Tests each supported RR type
  def test_3_add_rule_types
    pattern = 'be.ef'
    type = 'AAAA'
    dns_response = ['2001:db8:ac10:fe01::']

    hash = {'pattern' => pattern, 'type' => type, 'response' => dns_response}

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    hash.to_json,
                                    @@headers)

    check_response(rest_response)

    # Test AAAA type
    regex = %r{
      ^#{hash['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{hash['type']}\t+
      #{hash['response'][0]}$
    }x

    dig_output = `dig @localhost -p 5300 -t #{hash['type']} #{hash['pattern']}`
    assert_match(regex, dig_output)

    hash['type'] = 'CNAME'
    hash['response'] = ['fe.eb.']

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    hash.to_json,
                                    @@headers)

    check_response(rest_response)

    # Test CNAME type
    regex = %r{
      ^#{hash['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{hash['type']}\t+
      #{hash['response'][0]}$
    }x

    dig_output = `dig @localhost -p 5300 -t #{hash['type']} #{hash['pattern']}`
    assert_match(regex, dig_output)

    hash['type'] = 'HINFO'
    hash['response'] = ['M6800', 'VMS']

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    hash.to_json,
                                    @@headers)

    check_response(rest_response)

    # Test HINFO type
    regex = %r{
      ^#{hash['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{hash['type']}\t+
      "#{hash['response'][0]}"\s+
      "#{hash['response'][1]}"$
    }x

    dig_output = `dig @localhost -p 5300 -t #{hash['type']} #{hash['pattern']}`
    assert_match(regex, dig_output)

    hash['type'] = 'MINFO'
    hash['response'] = ['rmail.be.ef.', 'email.be.ef.']

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    hash.to_json,
                                    @@headers)

    check_response(rest_response)

    # Test MINFO type
    regex = %r{
      ^#{hash['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{hash['type']}\t+
      #{hash['response'][0]}\s+
      #{hash['response'][1]}$
    }x

    dig_output = `dig @localhost -p 5300 -t #{hash['type']} #{hash['pattern']}`
    assert_match(regex, dig_output)

    hash['type'] = 'MX'
    hash['response'] = [10, 'mail.be.ef.']

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    hash.to_json,
                                    @@headers)

    check_response(rest_response)

    # Test MX type
    regex = %r{
      ^#{hash['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{hash['type']}\t+
      #{hash['response'][0]}\s+
      #{hash['response'][1]}$
    }x

    dig_output = `dig @localhost -p 5300 -t #{hash['type']} #{hash['pattern']}`
    assert_match(regex, dig_output)

    hash['type'] = 'NS'
    hash['response'] = ['ns.be.ef.']

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    hash.to_json,
                                    @@headers)

    check_response(rest_response)

    # Test NS type
    regex = %r{
      ^#{hash['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{hash['type']}\t+
      #{hash['response'][0]}$
    }x

    dig_output = `dig @localhost -p 5300 -t #{hash['type']} #{hash['pattern']}`
    assert_match(regex, dig_output)

    hash['type'] = 'PTR'
    hash['response'] = ['4.3.2.1.in-addr.arpa.']

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    hash.to_json,
                                    @@headers)

    check_response(rest_response)

    # Test PTR type
    regex = %r{
      ^#{hash['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{hash['type']}\t+
      #{hash['response'][0]}$
    }x

    dig_output = `dig @localhost -p 5300 -t #{hash['type']} #{hash['pattern']}`
    assert_match(regex, dig_output)

    hash['type'] = 'SOA'
    hash['response'] = [
      "ns.#{hash['pattern']}.",
      "mail.#{hash['pattern']}.",
      2012031500,
      10800,
      3600,
      604800,
      3600
    ]

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    hash.to_json,
                                    @@headers)

    check_response(rest_response)

    # Test SOA type
    regex = %r{
      ^#{hash['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{hash['type']}\t+
      .*
    }x

    dig_output = `dig @localhost -p 5300 -t #{hash['type']} #{hash['pattern']}`
    assert_match(regex, dig_output)

    hash['type'] = 'TXT'
    hash['response'] = ['When in doubt, use brute force!']

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    hash.to_json,
                                    @@headers)

    check_response(rest_response)

    # Test TXT type
    regex = %r{
      ^#{hash['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{hash['type']}\t+
      "#{hash['response'][0].gsub!(' ', '\s')}"$
    }x

    dig_output = `dig @localhost -p 5300 -t #{hash['type']} #{hash['pattern']}`
    assert_match(regex, dig_output)

    hash['type'] = 'WKS'
    hash['response'] = ['9.9.9.9', 6, 0]

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    hash.to_json,
                                    @@headers)

    check_response(rest_response)

    # Test WKS type
    regex = %r{
      ^#{hash['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{hash['type']}\t+
      #{hash['response'][0]}\s
      0\s5\s6$
    }x

    dig_output = `dig @localhost -p 5300 -t #{hash['type']} #{hash['pattern']}`
    assert_match(regex, dig_output)

    hash['type'] = 'BeEF'

    # Test that an invalid RR returns 400
    assert_raise RestClient::BadRequest do
      rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                      hash.to_json,
                                      @@headers)
    end
  end

  def check_response(response)
    assert_not_nil(response.body)
    assert_equal(200, response.code)

    result = JSON.parse(response.body)

    assert(result['success'])
    assert(result['id'])
  end

end
