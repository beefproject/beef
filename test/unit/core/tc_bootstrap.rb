#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_Bootstrap < Test::Unit::TestCase

  def setup
    $root_dir = "../../"
    $:.unshift File.join( %w{ ../../ } )
    BeEF::Core::Configuration.new("#{$root_dir}/config.yaml")
  end

  def teardown
    $root_dir = nil
  end

  #
  # Test the core is functional
  #
  def test_bootstrap
    assert_nothing_raised do
      require 'core/bootstrap'
    end
  end

end

