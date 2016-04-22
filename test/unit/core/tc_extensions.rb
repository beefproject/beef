#
# Copyright (c) 2006-2016 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_Extensions < Test::Unit::TestCase

  def setup
    $:.unshift(File.join(File.expand_path(File.dirname(__FILE__)), '.'))
    $root_dir = File.expand_path('../../../../', __FILE__)
  end
  
  #
  # Test that extensions are loading properly
  #
  def test_extensions
    assert_nothing_raised do
      BeEF::Extensions.load
    end

    enabled_extensions = BeEF::Core::Configuration.instance.get('beef.extension').select {|k,v|
      v['enable'] == true
    }

    enabled_extensions.each do |k,v|
      assert(v.has_key?('name'))
      assert(v.has_key?('enable'))
      assert(v.has_key?('loaded'))
    end

    enabled_extensions.each do |k,v|
      assert(v['loaded'], 'Extension is enabled but was not loaded')
    end
  end

  def test_safe_client_debug_log
    Dir['../../extensions/**/*.js'].each do |path|
      next if /extensions\/admin_ui/.match(path) # skip this file
      File.open(path) do |f|
        f.grep(/\W*console\.log\W*\(/im) do |line|
          assert(false, "Function 'console.log' used instead of 'beef.debug' in command module: " + path + ':' + line)
        end
      end
    end
  end

end
