#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
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
