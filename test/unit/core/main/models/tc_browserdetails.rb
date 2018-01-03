#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_BrowserDetails < Test::Unit::TestCase

  def setup
    $:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '.'))
    $root_dir = File.expand_path('../../../../', __FILE__)

    @session = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def shutdown
    $root_dir = nil
  end

  # Connects to in-memory database (does not test anything)
  def test_01_database
    DataMapper.setup(:default, 'sqlite3::memory:')
    DataMapper.auto_migrate!
  end

  # Tests nil key value returns empty string
  def test_02_set_nil_values
    key_value = nil
    BeEF::Core::Models::BrowserDetails.set(@session, 'key_with_nil_value', key_value).to_s
    assert_equal '', BeEF::Core::Models::BrowserDetails.get(@session, 'key_with_nil_valule').to_s
  end

  # Tests get/set browser details
  def test_03_set_browser_details
    key_name = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    key_value = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    BeEF::Core::Models::BrowserDetails.set(@session, key_name, key_value).to_s
    assert_equal key_value, BeEF::Core::Models::BrowserDetails.get(@session, key_name).to_s
  end

  # Tests updating browser details
  def test_04_update_browser_details
    key_name = (0...10).map { ('a'..'z').to_a[rand(26)] }.join

    key_value = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    BeEF::Core::Models::BrowserDetails.set(@session, key_name, key_value).to_s
    assert_equal key_value, BeEF::Core::Models::BrowserDetails.get(@session, key_name).to_s

    key_value = (0...10).map { ('a'..'z').to_a[rand(26)] }.join
    BeEF::Core::Models::BrowserDetails.set(@session, key_name, key_value).to_s
    assert_equal key_value, BeEF::Core::Models::BrowserDetails.get(@session, key_name).to_s
  end
end
