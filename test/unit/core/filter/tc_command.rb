#
#   Copyright 2012 Wade Alcorn wade@bindshell.net
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
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
