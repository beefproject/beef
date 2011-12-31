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

class TC_Filesystem < Test::Unit::TestCase

  def setup
    $root_dir="../../"
    $:.unshift File.join( %w{ ../../ } )
  end

  def basic_file_test(test_file)
    assert((File.file?(test_file)), "The file does not exist: " + test_file)
    assert((not File.zero?(test_file)), "The file is empty: " + test_file)
  end

  #
  # Test the consistancy of the filesystem
  #
  
  def test_beef_file
    test_file = '../../beef'
    
    basic_file_test(test_file)
    assert((File.executable?(test_file)), "The file is not executable: " + test_file)
  end

  def test_config_file
    test_file = '../../config.yaml'
    
    basic_file_test(test_file)
  end

  def test_install_file
    test_file = '../../install'
    
    basic_file_test(test_file)
  end

  def test_main_directories_exist
    assert(File.executable?('../../core'))
    assert(File.executable?('../../modules'))
    assert(File.executable?('../../extensions'))
  end


end
