#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_Network < Test::Unit::TestCase

  def setup
    $:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '.'))
    $root_dir = File.expand_path('../../../../', __FILE__)

    require 'extensions/network/models/network_service'
    require 'extensions/network/models/network_host'
  end

  def shutdown
    $root_dir = nil
  end

  # Connects to in-memory database (does not test anything)
  def test_01_database
    DataMapper.setup(:default, 'sqlite3::memory:')
    DataMapper.auto_migrate!
  end

  # Tests procedure for properly adding new host
  def test_02_add_host_good
    assert_nothing_raised do
      BeEF::Core::Models::NetworkHost.add(:hooked_browser_id => '1234', :ip => '127.0.0.1')
      raise "Adding network host failed" if BeEF::Core::Models::NetworkHost.all(:hooked_browser_id => '1234', :ip => '127.0.0.1').empty?
    end
  end

  # Tests procedure for properly adding new service
  def test_03_add_service_good
    assert_nothing_raised do
      BeEF::Core::Models::NetworkService.add(:hooked_browser_id => '1234', :proto => 'http', :ip => '127.0.0.1', :port => 80, :type => 'Apache')
      raise "Adding network service failed" if BeEF::Core::Models::NetworkService.all(:hooked_browser_id => '1234', :ip => '127.0.0.1').empty?
    end
  end

end
