#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_IpecTunnel < Test::Unit::TestCase

  class << self

    def startup
      $root_dir = '../../'
      $:.unshift(File.expand_path($root_dir))

      # load extension
      require 'extensions/ipec/extension'

      # load config
      BeEF::Core::Configuration.new(File.join($root_dir, 'config.yaml'))
      config = BeEF::Core::Configuration.instance
      config.load_extensions_config
      @@ipec_config = config.get('beef.extension.ipec')
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
    assert(@@ipec_config.has_key?('enable'))
  end

  # Verifies public interface
  def test_03_interface
    @@ipec_junk_calc = BeEF::Extension::Ipec::JunkCalculator.instance
    assert_respond_to(@@ipec_junk_calc, :bind_junk_calculator)
  end

end
