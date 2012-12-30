#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_Modules < Test::Unit::TestCase

  def setup
    $:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '.'))
    $root_dir = File.expand_path('../../../../', __FILE__)
  end
  
  #
  # Test that modules are loading properly
  #
  def test_modules
    assert_nothing_raised do
      BeEF::Modules.load
    end
    
    BeEF::Core::Configuration.instance.get('beef.module').select {|k,v| v['enable'] == true and v['category'] != nil }.each { |k,v|
      assert((BeEF::Module.is_present(k)),"#{k} is not present in config - buh?")
    }
    
    BeEF::Core::Configuration.instance.get('beef.module').select {|k,v| v['enable'] == true and v['category'] != nil }.each { |k,v|
      assert((BeEF::Module.is_enabled(k)),"#{k} is not enabled in config - ruhhh?")
    }
    
    assert_nothing_raised do
      BeEF::Core::Configuration.instance.get('beef.module').select {|k,v| v['enable'] == true and v['category'] != nil }.each { |k,v|
        BeEF::Module.hard_load(k)
      }
    end
    
    BeEF::Core::Configuration.instance.get('beef.module').select {|k,v| v['enable'] == true and v['category'] != nil }.each { |k,v|
      assert((BeEF::Module.is_loaded(k)), "#{k} is not loaded - even though it should be - rut roh?")
    }

    BeEF::Core::Configuration.instance.get('beef.module').select {|k,v| v['enable'] == true and v['category'] != nil }.each { |k,v|
      BeEF::Core::Configuration.instance.get('beef.module.'+k+'.target').each { |t,tt|
        if tt.class == Array
          assert_not_equal(tt.length,0,"#{k} does not have valid TARGET configuration")
        end
      }
    }
    
  end

end
