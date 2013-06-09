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

  # Tests POST /api/dns/rule handler with valid input
  def test_1_add_rule_good
    pattern = 'foo.bar'
    type = 'A'
    dns_response = ['1.2.3.4']

    json = {:pattern => pattern, :type => type, :response => dns_response}.to_json

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    json,
                                    @@headers)

    check_rest_response(rest_response)

    result = JSON.parse(rest_response.body)
    first_id = result['id']

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    json,
                                    @@headers)

    # Verify that adding an existing rule returns its id
    check_rest_response(rest_response)

    result = JSON.parse(rest_response.body)
    second_id = result['id']

    assert_equal(first_id, second_id)
  end

  # Tests POST /api/dns/rule handler with invalid input
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

  # Tests POST /api/dns/rule handler with each supported RR type
  def test_3_add_rule_types
    pattern = 'be.ef'
    type = 'AAAA'
    response = ['2001:db8:ac10:fe01::']

    # Test AAAA type
    rule = {'pattern' => pattern, 'type' => type, 'response' => response}

    regex = %r{
      ^#{rule['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{rule['type']}\t+
      #{rule['response'][0]}$
    }x

    add_rule(rule)
    check_dns_response(regex, rule['type'], rule['pattern'])

    # Test CNAME type
    rule['type'] = 'CNAME'
    rule['response'] = ['fe.eb.']

    regex = %r{
      ^#{rule['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{rule['type']}\t+
      #{rule['response'][0]}$
    }x

    add_rule(rule)
    check_dns_response(regex, rule['type'], rule['pattern'])

    # Test HINFO type
    rule['type'] = 'HINFO'
    rule['response'] = ['M6800', 'VMS']

    regex = %r{
      ^#{rule['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{rule['type']}\t+
      "#{rule['response'][0]}"\s+
      "#{rule['response'][1]}"$
    }x

    add_rule(rule)
    check_dns_response(regex, rule['type'], rule['pattern'])

    # Test MINFO type
    rule['type'] = 'MINFO'
    rule['response'] = ['rmail.be.ef.', 'email.be.ef.']

    regex = %r{
      ^#{rule['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{rule['type']}\t+
      #{rule['response'][0]}\s+
      #{rule['response'][1]}$
    }x

    add_rule(rule)
    check_dns_response(regex, rule['type'], rule['pattern'])

    # Test MX type
    rule['type'] = 'MX'
    rule['response'] = [10, 'mail.be.ef.']

    regex = %r{
      ^#{rule['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{rule['type']}\t+
      #{rule['response'][0]}\s+
      #{rule['response'][1]}$
    }x

    add_rule(rule)
    check_dns_response(regex, rule['type'], rule['pattern'])

    # Test NS type
    rule['type'] = 'NS'
    rule['response'] = ['ns.be.ef.']

    regex = %r{
      ^#{rule['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{rule['type']}\t+
      #{rule['response'][0]}$
    }x

    add_rule(rule)
    check_dns_response(regex, rule['type'], rule['pattern'])

    # Test PTR type
    rule['type'] = 'PTR'
    rule['response'] = ['4.3.2.1.in-addr.arpa.']

    regex = %r{
      ^#{rule['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{rule['type']}\t+
      #{rule['response'][0]}$
    }x

    add_rule(rule)
    check_dns_response(regex, rule['type'], rule['pattern'])

    # Test SOA type
    rule['type'] = 'SOA'
    rule['response'] = [
      "ns.#{rule['pattern']}.",
      "mail.#{rule['pattern']}.",
      2012031500,
      10800,
      3600,
      604800,
      3600
    ]

    regex = %r{
      ^#{rule['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{rule['type']}\t+
      .*
    }x

    add_rule(rule)
    check_dns_response(regex, rule['type'], rule['pattern'])

    # Test TXT type
    rule['type'] = 'TXT'
    rule['response'] = ['b33f_is_s0_l33t']

    regex = %r{
      ^#{rule['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{rule['type']}\t+
      "#{rule['response'][0]}"$
    }x

    add_rule(rule)
    check_dns_response(regex, rule['type'], rule['pattern'])

    # Test WKS type
    rule['type'] = 'WKS'
    rule['response'] = ['9.9.9.9', 6, 0]

    regex = %r{
      ^#{rule['pattern']}\.\t+
      \d+\t+
      IN\t+
      #{rule['type']}\t+
      #{rule['response'][0]}\s
      0\s5\s6$
    }x

    add_rule(rule)
    check_dns_response(regex, rule['type'], rule['pattern'])

    # Test that an invalid RR returns 400
    rule['type'] = 'BeEF'

    assert_raise RestClient::BadRequest do
      rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                      rule.to_json,
                                      @@headers)
    end
  end

  # Tests GET /api/dns/rule/:id handler with valid input
  def test_4_get_rule_good
    pattern = 'wheres.the.beef'
    type = 'A'
    dns_response = ['4.2.4.2']

    json = {:pattern => pattern, :type => type, :response => dns_response}.to_json

    rest_response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    json,
                                    @@headers)

    check_rest_response(rest_response)
    result = JSON.parse(rest_response.body)
    id = result['id']

    rest_response = RestClient.get("#{RESTAPI_DNS}/rule/#{id}", :params => {:token => @@token})

    assert_not_nil(rest_response.body)
    assert_equal(200, rest_response.code)

    result = JSON.parse(rest_response.body)

    assert_equal(id, result['id'])
    assert_equal(pattern, result['pattern'])
    assert_equal(type, result['type'])
    assert_equal(dns_response, result['response'])
  end

  # Tests GET /api/dns/rule/:id handler with invalid input
  def test_4_get_rule_bad
    id = 42

    assert_raise RestClient::ResourceNotFound do
      response = RestClient.get("#{RESTAPI_DNS}/rule/#{id}", :params => {:token => @@token})
    end

    id = '(*_*)'

    assert_raise RestClient::BadRequest do
      RestClient.get("#{RESTAPI_DNS}/rule/#{id}", :params => {:token => @@token})
    end
  end

  # Tests GET /api/dns/ruleset handler
  def test_4_get_ruleset
    rest_response = RestClient.get("#{RESTAPI_DNS}/ruleset", :params => {:token => @@token})

    assert_not_nil(rest_response.body)
    assert_equal(200, rest_response.code)

    result = JSON.parse(rest_response.body)
    assert_equal(15, result['count'])

    result['ruleset'].each do |rule|
      assert(rule['id'])
      assert(rule['pattern'])
      assert(rule['type'])
      assert(rule['response'].length != 0)
    end
  end

  private

  # Adds a new DNS rule
  def add_rule(params)
    response = RestClient.post("#{RESTAPI_DNS}/rule?token=#{@@token}",
                                    params.to_json,
                                    @@headers)

    check_rest_response(response)
  end

  # Standard assertions for verifying response from RESTful API
  def check_rest_response(response)
    assert_not_nil(response.body)
    assert_equal(200, response.code)

    result = JSON.parse(response.body)

    assert(result['success'])
    assert(result['id'])
  end

  # TODO: Use BeEF::Core::Configuration to get address and port values.

  # Compares output of dig command against regex
  def check_dns_response(regex, type, pattern)
    dig_output = `dig @localhost -p 5300 -t #{type} #{pattern}`
    assert_match(regex, dig_output)
  end

end
