#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_Proxy < Test::Unit::TestCase

  def setup
    $:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '.'))
    $root_dir = File.expand_path('../../../../', __FILE__)
  end

  def test_proxy
    assert(true)
  end
  def test_delete
    assert(true)
  end
  def test_put
    assert(true)
  end
  def test_head
    assert(true)
  end
  def test_no_params
    assert(true)
  end
  def test_zero_values
    assert(true)
  end
  def test_one_values
    assert(true)
  end
  def test_neg_one_values
    assert(true)
  end

end
