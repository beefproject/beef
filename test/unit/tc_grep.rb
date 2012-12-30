#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require 'test/unit'

class TC_Grep < Test::Unit::TestCase

  def test_grep_eval
    Dir['../../**/*.rb'].each do |path|
      File.open( path ) do |f|
        next if /tc_grep.rb/.match(path) # skip this file
        next if /\/msf-test\//.match(path) # skip this file
        f.grep( /\Weval\W/im ) do |line|
          assert(false, "Illegal use of 'eval' in framework: " + path + ':' + line)
        end
      end
    end
    
  end

end
