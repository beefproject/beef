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
  def test_1_database
    DataMapper.setup(:default, 'sqlite3::memory:')
    DataMapper.auto_migrate!
  end

  # Checks for required settings in config file
  def test_2_config
    assert(@@dns_config.has_key?('address'))
    assert(@@dns_config.has_key?('port'))
  end

  # Verifies public interface
  def test_3_interface
    @@dns = BeEF::Extension::Dns::Server.instance

    assert(@@dns.respond_to?('run_server'))
    assert(@@dns.respond_to?('add_rule'))
    assert(@@dns.respond_to?('remove_rule'))
    assert(@@dns.respond_to?('get_ruleset'))
    assert(@@dns.respond_to?('get_rule'))
  end

  # Starts DNS server (does not test anything)
  def test_4_run_server
    address = @@dns_config['address']
    port    = @@dns_config['port']

    @@dns.run_server(address, port)
    sleep(3)
  end

  # Tests procedure for adding new DNS rules
  def test_5_add_rule
    id = nil
    same_id = nil

    response = '1.2.3.4'

    # Add a new rule normally
    assert_nothing_raised do
      id = @@dns.add_rule('foo.bar', IN::A) do |transaction|
        transaction.respond!('1.2.3.4')
      end
    end

    assert_not_nil(id)
    assert_equal(7, id.length)

    # Attempt to add an existing rule
    assert_nothing_raised do
      same_id = @@dns.add_rule('foo.bar', IN::A) do |transaction|
        transaction.respond!('1.2.3.4')
      end
    end

    assert_not_nil(same_id)
    assert_equal(same_id, id)
  end

  # Tests retrieval of DNS rules
  def test_6_get_rule
    id = @@dns.add_rule('be.ef', IN::A) do |transaction|
      transaction.respond!('1.1.1.1')
    end

    rule = @@dns.get_rule(id)

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

end
