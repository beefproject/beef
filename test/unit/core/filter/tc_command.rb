require 'test/unit'
require 'webrick'

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
