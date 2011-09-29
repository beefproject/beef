require 'test/unit/ui/console/testrunner'

require './filter/tc_base'
require './filter/tc_command'

class TS_BeefTests
  def self.suite
    suite = Test::Unit::TestSuite.new(name="BeEF TestSuite")
    suite << TC_Filter.suite
    return suite
  end
end

Test::Unit::UI::Console::TestRunner.run(TS_BeefTests)
