#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_Loader < Test::Unit::TestCase

  def setup
    $root_dir = "../../"
    $:.unshift File.join( %w{ ../../ } )
  end

  def teardown
    $root_dir = nil
  end

  #
  # Test the loader is functional
  #
  def test_loader
    assert_nothing_raised do
      require 'core/loader'
    end
  end

end
