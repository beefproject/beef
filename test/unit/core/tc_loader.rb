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
