#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_Webrtc < Test::Unit::TestCase

  class << self

    def startup
      $root_dir = '../../'
      $:.unshift(File.expand_path($root_dir))

      # load extension
      require 'extensions/webrtc/extension'

      # load config
      BeEF::Core::Configuration.new(File.join($root_dir, 'config.yaml'))
      config = BeEF::Core::Configuration.instance
      config.load_extensions_config
      @@webrtc_config = config.get('beef.extension.webrtc')
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
    assert(@@webrtc_config.has_key?('enable'))
    assert(@@webrtc_config.has_key?('stunservers'))
    assert(@@webrtc_config.has_key?('turnservers'))
  end

end
