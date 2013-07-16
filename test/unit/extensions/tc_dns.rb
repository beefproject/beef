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
    assert_respond_to(@@dns, :get_ruleset)
    assert_respond_to(@@dns, :get_rule)
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

    assert(response.class == Array)
    assert(response.length > 0)
    assert_equal('1.1.1.1', response[0])
  end

  # Tests retrieval of invalid DNS rules
  def test_09_get_rule_bad
    rule = @@dns.get_rule(42)

    assert_equal(Hash, rule.class)
    assert(rule.length == 0)
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

end

# Suppresses unnecessary output from RubyDNS
module Kernel

  def puts(*args); end

end
