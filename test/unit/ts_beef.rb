
begin
  require 'test/unit/ui/console/testrunner'
rescue LoadError
  puts "The following instruction failed: require 'test/unit/ui/console/testrunner'"
  puts "Please run: sudo gem install test-unit-full"
  exit
end

require './core/filter/tc_base'
require './core/filter/tc_command'
require './core/tc_loader'
require './core/tc_core'
require './core/tc_api'

class TS_BeefTests
  def self.suite
    suite = Test::Unit::TestSuite.new(name="BeEF TestSuite")
    suite << TC_Filter.suite
    suite << TC_Loader.suite
    suite << TC_Core.suite
    suite << TC_Api.suite
    return suite
  end
end

Test::Unit::UI::Console::TestRunner.run(TS_BeefTests)
