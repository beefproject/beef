#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

require '../../core/filters/base'
require '../../core/filters/command'

class TC_Filter < Test::Unit::TestCase
  
  def test_has_valid_param_chars
    assert((not BeEF::Filters::has_valid_param_chars?(nil)), 'Nil')
    assert((not BeEF::Filters::has_valid_param_chars?("")), 'Empty string')
    assert((BeEF::Filters::has_valid_param_chars?("A")), 'Single char')
    assert((not BeEF::Filters::has_valid_param_chars?("+")), 'Single invalid char')
  end
    
end
