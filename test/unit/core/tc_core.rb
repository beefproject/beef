#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_Core < Test::Unit::TestCase

  def setup
    $root_dir = "../../"
    $:.unshift File.join( %w{ ../../ } )
  end

  def teardown
    $root_dir = nil
  end

  #
  # Test the core is functional
  #
  def test_core
    assert_nothing_raised do
      require 'core/core'
    end
  end

end

