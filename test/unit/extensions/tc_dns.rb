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

  def setup
    DataMapper.setup(:default, 'sqlite3::memory:')
    DataMapper.auto_migrate!
  end

  # Checks for required settings in config file
  def test_1_config
    assert(@@dns_config.has_key?('address'))
    assert(@@dns_config.has_key?('port'))
  end

  # Verifies public interface
  def test_2_interface
    @@dns = BeEF::Extension::Dns::Server.instance

    assert(@@dns.respond_to?('run_server'))
    assert(@@dns.respond_to?('add_rule'))
    assert(@@dns.respond_to?('remove_rule'))
    assert(@@dns.respond_to?('get_ruleset'))
    assert(@@dns.respond_to?('get_rule'))
  end

end
