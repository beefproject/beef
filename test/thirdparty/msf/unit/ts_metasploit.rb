#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# Common lib for BeEF tests
require '../../../common/ts_common'

begin
  require 'msfrpc-client'
rescue LoadError
  puts "The following instruction failed: require 'msfrpc-client'"
  puts "Please run: sudo gem install msfrpc-client"
  exit
end

require './check_environment'
require './tc_metasploit'

class TS_BeefTests
  def self.suite

    suite = Test::Unit::TestSuite.new(name="BeEF Metasploit Test Suite")
    suite << TC_CheckEnvironment.suite
    suite << TC_Metasploit.suite

    return suite
  end
end

Test::Unit::UI::Console::TestRunner.run(TS_BeefTests)

