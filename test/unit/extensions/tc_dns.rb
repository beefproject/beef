#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'
require 'resolv'

class TC_Dns < Test::Unit::TestCase

  IN = Resolv::DNS::Resource::IN

  class << self

    def startup
      $root_dir = '../../'
      $:.unshift(File.expand_path($root_dir))

      require 'extensions/dns/extension'

      BeEF::Core::Configuration.new(File.join($root_dir, 'config.yaml'))
      @@config = BeEF::Core::Configuration.instance
      @@config.load_extensions_config

      @@dns_config = @@config.get('beef.extension.dns')
      @@dns = BeEF::Extension::Dns::Server.instance
    end

    def shutdown
      $root_dir = nil
    end

  end

  # Connects to in-memory database (does not test anything)
  def test_01_database
    DataMapper.setup(:default, 'sqlite3::memory:')
    DataMapper.auto_migrate!
  end

  # Checks for required settings in config file
  def test_02_config
    assert(@@dns_config.has_key?('protocol'))
    assert(@@dns_config.has_key?('address'))
    assert(@@dns_config.has_key?('port'))
    assert(@@dns_config.has_key?('upstream'))
  end

  # Verifies public interface
  def test_03_interface
    assert_respond_to(@@dns, :add_rule)
    assert_respond_to(@@dns, :get_rule)
    assert_respond_to(@@dns, :remove_rule!)
    assert_respond_to(@@dns, :get_ruleset)
    assert_respond_to(@@dns, :remove_ruleset!)
  end

  # Tests procedure for properly adding new DNS rules
  def test_04_add_rule_good
    id = nil
    response = '1.2.3.4'
    assert_nothing_raised do
      id = @@dns.add_rule(
        :pattern => 'foo.bar',
        :resource => IN::A,
        :response => [response] ) do |transaction|
          transaction.respond!(response)
      end
    end

    assert_not_nil(id)

    id = nil
    response = '9.9.9.9'
    assert_nothing_raised do
      id = @@dns.add_rule(
        :pattern => %r{i\.(love|hate)\.beef\.com?},
        :resource => IN::A,
        :response => [response] ) do |transaction|
          transaction.respond!(response)
      end
    end

    assert_not_nil(id)

    domains = %w(
      i.hate.beef.com
      i.love.beef.com
      i.love.beef.co
      i.love.beef.co )
    assert_nothing_raised do
      domains.each do |domain|
        id = @@dns.add_rule(
          :pattern => %r{i\.(love|hate)\.beef\.com?},
          :resource => IN::A,
          :response => domain ) do |transaction|
            transaction.respond!(domain)
        end
        assert_not_nil(id)
      end
    end
  end

  # Tests addition of new rules with invalid parameters
  def test_05_add_rule_bad
    id = nil
    same_id = nil

    pattern = 'j.random.hacker'
    response = '4.2.4.2'

    # Add the same rule twice
    assert_nothing_raised do
      id = @@dns.add_rule(
        :pattern => pattern,
        :resource => IN::A,
        :response => [response] ) do |transaction|
          transaction.respond!(response)
      end
    end

    assert_nothing_raised do
      same_id = @@dns.add_rule(
        :pattern => pattern,
        :resource => IN::A,
        :response => [response] ) do |transaction|
          transaction.respond!(response)
      end
    end

    assert_equal(id, same_id)
  end

  # Verifies the proper format for rule identifiers
  def test_06_id_format
    pattern = 'dead.beef'
    response = '2.2.2.2'
    id = nil
    assert_nothing_raised do
      id = @@dns.add_rule(
        :pattern => pattern,
        :resource => IN::A,
        :response => [response] ) do |transaction|
          transaction.respond!(response)
      end
    end
    assert_equal(8, id.length)
    assert_not_nil(id =~ /^\h{8}$/)
  end

  # Tests retrieval of valid DNS rules
  def test_07_get_rule_good
    pattern = 'be.ef'
    response = '1.1.1.1'
    id = nil
    assert_nothing_raised do
      id = @@dns.add_rule(
        :pattern => pattern,
        :resource => IN::A,
        :response => [response] ) do |transaction|
          transaction.respond!(response)
      end
    end

    rule = @@dns.get_rule(id)

    assert_equal(Hash, rule.class)
    assert(rule.length > 0)

    assert(rule.has_key?(:id))
    assert(rule.has_key?(:pattern))
    assert(rule.has_key?(:resource))
    assert(rule.has_key?(:response))

    assert_equal(id, rule[:id])
    assert_equal('be.ef', rule[:pattern])
    assert_equal('A', rule[:resource])

    assert_equal(Array, rule[:response].class)
    assert(rule[:response].length > 0)
    assert_equal(response, rule[:response][0])
  end

  # Tests retrieval of invalid DNS rules
  def test_08_get_rule_bad
    rule = @@dns.get_rule(42)
    assert_equal(nil, rule)
  end

  # Tests the removal of existing DNS rules
  def test_09_remove_rule_good
    pattern = 'hack.the.gibson'
    response = '1.9.9.5'
    id = nil
    assert_nothing_raised do
      id = @@dns.add_rule(
        :pattern => pattern,
        :resource => IN::A,
        :response => [response] ) do |transaction|
          transaction.respond!(response)
      end
    end

    removed = @@dns.remove_rule!(id)

    assert(removed)
  end

  # Tests the removal of unknown DNS rules
  def test_10_remove_rule_bad
    removed = @@dns.remove_rule!(42)

    assert(!removed)
  end

  # Tests the retrieval of the entire DNS ruleset
  def test_11_get_ruleset
    ruleset = @@dns.get_ruleset
    ruleset.sort! { |a, b| a[:pattern] <=> b[:pattern] }

    assert_equal(Array, ruleset.class)
    assert_equal(5, ruleset.length)

    check_rule(ruleset[0], {:pattern  => 'be.ef',
                            :resource => 'A',
                            :response => '1.1.1.1' })
    check_rule(ruleset[1], {:pattern  => 'dead.beef',
                            :resource => 'A',
                            :response => '2.2.2.2' })
    check_rule(ruleset[2], {:pattern  => 'foo.bar',
                            :resource => 'A',
                            :response => '1.2.3.4' })
    check_rule(ruleset[3], {:pattern  => 'i\.(love|hate)\.beef\.com?',
                            :resource => 'A',
                            :response => '9.9.9.9' })
    check_rule(ruleset[4], {:pattern  => 'j.random.hacker',
                            :resource => 'A',
                            :response => '4.2.4.2' })
  end

  # Tests the removal of the entire DNS ruleset
  def test_12_remove_ruleset
    removed = @@dns.remove_ruleset!
    ruleset = @@dns.get_ruleset

    assert(removed)
    assert_equal(0, ruleset.length)
  end


  # Tests each supported type of query failure
  def test_13_failure_types
    begin
      id = @@dns.add_rule(
        :pattern => 'noerror.beef.com',
        :resource => IN::A,
        :response => ['1.2.3.4'] ) do |transaction|
          transaction.failure!(:NoError)
      end
      #check_failure_status(id, :NoError)
    end

    begin
      id = @@dns.add_rule(
        :pattern => 'formerr.beef.com',
        :resource => IN::A,
        :response => ['1.2.3.4'] ) do |transaction|
          transaction.failure!(:FormErr)
      end
      #check_failure_status(id, :FormErr)
    end

    begin
      id = @@dns.add_rule(
        :pattern => 'servfail.beef.com',
        :resource => IN::A,
        :response => ['1.2.3.4'] ) do |transaction|
          transaction.failure!(:ServFail)
      end
      #check_failure_status(id, :ServFail)
    end

    begin
      id = @@dns.add_rule(
        :pattern => 'nxdomain.beef.com',
        :resource => IN::A,
        :response => ['1.2.3.4'] ) do |transaction|
          transaction.failure!(:NXDomain)
      end
      #check_failure_status(id, :NXDomain)
    end

    begin
      id = @@dns.add_rule(
        :pattern => 'notimp.beef.com',
        :resource => IN::A,
        :response => ['1.2.3.4'] ) do |transaction|
          transaction.failure!(:NotImp)
      end
      #check_failure_status(id, :NotImp)
    end

    begin
      id = @@dns.add_rule(
        :pattern => 'refused.beef.com',
        :resource => IN::A,
        :response => ['1.2.3.4'] ) do |transaction|
          transaction.failure!(:Refused)
      end
      #check_failure_status(id, :Refused)
    end

    begin
      id = @@dns.add_rule(
        :pattern => 'notauth.beef.com',
        :resource => IN::A,
        :response => ['1.2.3.4'] ) do |transaction|
          transaction.failure!(:NotAuth)
      end
      #check_failure_status(id, :NotAuth)
    end
  end

  private

  # Compares each key in hash 'rule' with the respective key in hash 'expected'
  def check_rule(rule, expected = {})
    assert_equal(expected[:pattern], rule[:pattern])
    assert_equal(expected[:resource], rule[:resource])
    assert_equal(expected[:response], rule[:response][0])
  end

  # Confirms that a query for the rule given in 'id' returns a 'resource' failure status
  def check_failure_status(id, resource)
    rule = @@dns.get_rule(id)
    status = resource.to_s.force_encoding('UTF-8').upcase
    assert_equal(status, rule[:response][0])

    check_dns_response(/status: #{status}/, rule[:resource], rule[:pattern])
  end

  # Compares output of dig command against regex
  def check_dns_response(regex, type, pattern)
    address = @@config.get('beef.extension.dns.address')
    port = @@config.get('beef.extension.dns.port')
    dig_output = IO.popen(["dig", "@#{address}", "-p", "#{port}", "-t", "#{type}", "#{pattern}"], 'r+').read
    assert_match(regex, dig_output)
  end

end

# Suppresses unnecessary output from RubyDNS
module Kernel

  def puts(*args)
    ;
  end

end
