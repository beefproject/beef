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

# Common lib for BeEF tests
require '../common/ts_common'

require 'capybara'
Capybara.run_server = false # we need to run our own BeEF server

require 'selenium/webdriver'

require './check_environment' # Basic log in and log out tests
require './tc_login' # Basic log in and log out tests

class TS_BeefIntegrationTests
  def self.suite

    suite = Test::Unit::TestSuite.new(name="BeEF Integration Test Suite")
    suite << TC_CheckEnvironment.suite
    suite << TC_login.suite

    return suite
  end
end

Test::Unit::UI::Console::TestRunner.run(TS_BeefIntegrationTests)

