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

require './core/filter/tc_base'
require './core/filter/tc_command'
require './core/tc_loader'
require './core/tc_core'
require './core/tc_api'
require './core/tc_modules'
require './core/tc_social_engineering'
require './core/tc_autorun'
require './core/tc_obfuscation'
require './core/tc_event_logger'
require './extensions/tc_xssrays'
require './extensions/tc_vnc'
require './extensions/tc_ipec_tunnel'
require './extensions/tc_hackverter'
require './extensions/tc_proxy'
require './extensions/tc_requester'
require './tc_grep'
require './tc_filesystem'

class TS_BeefTests
  def self.suite

    suite = Test::Unit::TestSuite.new(name="BeEF Unit Test Suite")
    suite << TC_Filter.suite
    suite << TC_Loader.suite
    suite << TC_Core.suite
    suite << TC_Api.suite
    suite << TC_Modules.suite
    suite << TC_Filesystem.suite
    suite << TC_Grep.suite
    suite << TC_SocialEngineering.suite
    suite << TC_Autorun.suite
    suite << TC_Xssrays.suite
    suite << TC_Vnc.suite
    suite << TC_Obfuscation.suite
    suite << TC_IpecTunnel.suite
    suite << TC_Requester.suite
    suite << TC_Proxy.suite
    suite << TC_Hackverter.suite
    suite << TC_EventLogger.suite

    return suite
  end
end

Test::Unit::UI::Console::TestRunner.run(TS_BeefTests)

