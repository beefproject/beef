#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
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
      config = BeEF::Core::Configuration.instance
      config.load_extensions_config

      @@dns_config = config.get('beef.extension.dns')
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
    assert(@@dns_config.has_key?('address'))
    assert(@@dns_config.has_key?('port'))
  end

  # Verifies public interface
  def test_03_interface
    @@dns = BeEF::Extension::Dns::Server.instance

    assert_respond_to(@@dns, :run_server)
    assert_respond_to(@@dns, :add_rule)
    assert_respond_to(@@dns, :remove_rule)
    assert_respond_to(@@dns, :get_rule)
    assert_respond_to(@@dns, :get_ruleset)
    assert_respond_to(@@dns, :remove_ruleset)
  end

  # Starts DNS server (does not test anything)
  def test_04_run_server
    address = @@dns_config['address']
    port    = @@dns_config['port']

    @@dns.run_server(address, port)
    sleep(3)
  end

  # Tests procedure for properly adding new DNS rules
  def test_05_add_rule_good
    id = nil

    assert_nothing_raised do
      id = @@dns.add_rule('foo.bar', IN::A) do |transaction|
        transaction.respond!('1.2.3.4')
      end
    end

    assert_not_nil(id)
  end

  # Tests that adding existing rules returns current id
  def test_06_add_rule_bad
    id = nil
    same_id = nil

    assert_nothing_raised do
      id = @@dns.add_rule('j.random.hacker', IN::A) do |transaction|
        transaction.respond!('4.2.4.2')
      end
    end

    assert_nothing_raised do
      same_id = @@dns.add_rule('j.random.hacker', IN::A) do |transaction|
        transaction.respond!('4.2.4.2')
      end
    end

    assert_equal(id, same_id)
  end

  # Verifies the proper format for rule identifiers
  def test_07_id_format
    id = @@dns.add_rule('dead.beef', IN::A) do |transaction|
      transaction.respond!('2.2.2.2')
    end

    assert_equal(7, id.length)
    assert_not_nil(id =~ /^\h{7}$/)
  end

  # Tests retrieval of valid DNS rules
  def test_08_get_rule_good
    id = @@dns.add_rule('be.ef', IN::A) do |transaction|
      transaction.respond!('1.1.1.1')
    end

    rule = @@dns.get_rule(id)

    assert_equal(Hash, rule.class)
    assert(rule.length > 0)

    assert(rule.has_key?(:id))
    assert(rule.has_key?(:pattern))
    assert(rule.has_key?(:type))
    assert(rule.has_key?(:response))

    assert_equal(id, rule[:id])
    assert_equal('be.ef', rule[:pattern])
    assert_equal('A', rule[:type])

    response = rule[:response]

    assert_equal(Array, response.class)
    assert(response.length > 0)
    assert_equal('1.1.1.1', response[0])
  end

  # Tests retrieval of invalid DNS rules
  def test_09_get_rule_bad
    rule = @@dns.get_rule(42)

    assert_equal(Hash, rule.class)
    assert_equal(0, rule.length)
  end

  # Tests the removal of existing DNS rules
  def test_10_remove_rule_good
    id = @@dns.add_rule('hack.the.gibson', IN::A) do |transaction|
      transaction.respond!('1.9.9.5')
    end

    removed = @@dns.remove_rule(id)

    assert(removed)
  end

  # Tests the removal of unknown DNS rules
  def test_11_remove_rule_bad
    removed = @@dns.remove_rule(42)

    assert(!removed)
  end

  # Tests the retrieval of the entire DNS ruleset
  def test_12_get_ruleset
    ruleset = @@dns.get_ruleset
    ruleset.sort! {|a, b| a[:pattern] <=> b[:pattern] }

    assert_equal(Array, ruleset.class)
    assert_equal(4, ruleset.length)

    check_rule(ruleset[0], {:pattern => 'be.ef', :type => 'A', :response => '1.1.1.1'})
    check_rule(ruleset[1], {:pattern => 'dead.beef', :type => 'A', :response => '2.2.2.2'})
    check_rule(ruleset[2], {:pattern => 'foo.bar', :type => 'A', :response => '1.2.3.4'})
    check_rule(ruleset[3], {:pattern => 'j.random.hacker', :type => 'A', :response => '4.2.4.2'})
  end

  # Tests the removal of the entire DNS ruleset
  def test_13_remove_ruleset
    removed = @@dns.remove_ruleset
    ruleset = @@dns.get_ruleset

    assert(removed)
    assert_equal(0, ruleset.length)
  end

  # Tests each supported type of query failure
  def test_14_failure_types
    begin
      id = @@dns.add_rule('noerror.beef.com', IN::A) do |transaction|
        transaction.failure!(:NoError)
      end

      check_failure_status(id, :NoError)
    end

    begin
      id = @@dns.add_rule('formerr.beef.com', IN::A) do |transaction|
        transaction.failure!(:FormErr)
      end

      check_failure_status(id, :FormErr)
    end

    begin
      id = @@dns.add_rule('servfail.beef.com', IN::A) do |transaction|
        transaction.failure!(:ServFail)
      end

      check_failure_status(id, :ServFail)
    end

    begin
      id = @@dns.add_rule('nxdomain.beef.com', IN::A) do |transaction|
        transaction.failure!(:NXDomain)
      end

      check_failure_status(id, :NXDomain)
    end

    begin
      id = @@dns.add_rule('notimp.beef.com', IN::A) do |transaction|
        transaction.failure!(:NotImp)
      end

      check_failure_status(id, :NotImp)
    end

    begin
      id = @@dns.add_rule('refused.beef.com', IN::A) do |transaction|
        transaction.failure!(:Refused)
      end

      check_failure_status(id, :Refused)
    end

    begin
      id = @@dns.add_rule('notauth.beef.com', IN::A) do |transaction|
        transaction.failure!(:NotAuth)
      end

      check_failure_status(id, :NotAuth)
    end
  end

  private

  # Compares each key in hash 'rule' with the respective key in hash 'expected'
  def check_rule(rule, expected = {})
    assert_equal(expected[:pattern], rule[:pattern])
    assert_equal(expected[:type], rule[:type])
    assert_equal(expected[:response], rule[:response][0])
  end

  # Compares output of dig command against regex
  def check_dns_response(regex, type, pattern)
    address = @@dns_config['address']
    port    = @@dns_config['port']

    dig_output = `dig @#{address} -p #{port} -t #{type} #{pattern}`
    assert_match(regex, dig_output)
  end

  # Confirms that a query for the rule given in 'id' returns a 'type' failure status
  def check_failure_status(id, type)
    rule   = @@dns.get_rule(id)
    status = type.to_s.force_encoding('UTF-8').upcase

    assert_equal(status, rule[:response][0])
    check_dns_response(/status: #{status}/, rule[:type], rule[:pattern])
  end

end

# Suppresses unnecessary output from RubyDNS
module Kernel

  def puts(*args); end

end
