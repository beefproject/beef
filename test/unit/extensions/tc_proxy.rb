#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_Proxy < Test::Unit::TestCase

  class << self

    def startup
      $root_dir = '../../'
      $:.unshift(File.expand_path($root_dir))

      # load extension
      require 'extensions/proxy/extension'

      # load config
      BeEF::Core::Configuration.new(File.join($root_dir, 'config.yaml'))
      config = BeEF::Core::Configuration.instance
      config.load_extensions_config
      @@proxy_config = config.get('beef.extension.proxy')
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
    assert(@@proxy_config.has_key?('enable'))
    assert(@@proxy_config.has_key?('address'))
    assert(@@proxy_config.has_key?('port'))
    assert(@@proxy_config.has_key?('key'))
    assert(@@proxy_config.has_key?('cert'))
  end

end
