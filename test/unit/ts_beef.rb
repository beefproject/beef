#
#   Copyright 2011 Wade Alcorn wade@bindshell.net
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

# @note Version check to ensure BeEF is running Ruby 1.9 >
if  RUBY_VERSION < '1.9'
  puts "\n"
  puts "Ruby version " + RUBY_VERSION + " is no longer supported. Please upgrade 1.9 or later."
  puts "\n"
  exit
end

begin
  require 'test/unit/ui/console/testrunner'
rescue LoadError
  puts "The following instruction failed: require 'test/unit/ui/console/testrunner'"
  puts "Please run: sudo gem install test-unit-full"
  exit
end

begin
  require 'curb'
rescue LoadError
  puts "The following instruction failed: require 'curb'"
  puts "Please run: sudo gem install curb"
  exit
end

if (ARGV[0] != 'no_msf')
  begin
    require 'msfrpc-client'
  rescue LoadError
    puts "The following instruction failed: require 'msfrpc-client'"
    puts "Please run: sudo gem install msfrpc-client"
    exit
  end
end

require './core/main/network_stack/handlers/dynamicreconstruction.rb'
require './core/filter/tc_base'
require './core/filter/tc_command'
require './core/tc_loader'
require './core/tc_core'
require './core/tc_api'
require './tc_grep'
require './tc_filesystem'
require './extensions/tc_metasploit'

class TS_BeefTests
  def self.suite
    suite = Test::Unit::TestSuite.new(name="BeEF TestSuite")
    suite << TC_Filter.suite
    suite << TC_Loader.suite
    suite << TC_Core.suite
    suite << TC_Api.suite
    suite << TC_Filesystem.suite
    suite << TC_Grep.suite
    suite << TC_DynamicReconstruction.suite
    suite << TC_Metasploit.suite unless (ARGV[0] == 'no_msf')
    return suite
  end
end

Test::Unit::UI::Console::TestRunner.run(TS_BeefTests)

