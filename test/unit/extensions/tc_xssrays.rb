#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_XssRays < Test::Unit::TestCase

  class << self

    def startup
      $root_dir = '../../'
      $:.unshift(File.expand_path($root_dir))

      # load extension
      require 'extensions/xssrays/extension'

      # load config
      BeEF::Core::Configuration.new(File.join($root_dir, 'config.yaml'))
      config = BeEF::Core::Configuration.instance
      config.load_extensions_config
      @@xssrays_config = config.get('beef.extension.xssrays')
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
    assert(@@xssrays_config.has_key?('enable'))
    assert(@@xssrays_config.has_key?('clean_timeout'))
    assert(@@xssrays_config.has_key?('cross_domain'))
    assert(@@xssrays_config.has_key?('js_console_logs'))
  end

  # Verifies public interface
  def test_03_interface
    @@xssrays = BeEF::Extension::Xssrays::API::Scan.new
    assert_respond_to(@@xssrays, :start_scan)
    assert_respond_to(@@xssrays, :add_to_body)
  end

end
