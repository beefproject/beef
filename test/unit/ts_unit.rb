#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# Common lib for BeEF tests
require '../common/ts_common'

require './core/filter/tc_base'
require './core/filter/tc_command'
require './core/main/network_stack/handlers/redirector'
require './core/tc_loader'
require './core/tc_core'
require './core/tc_api'
require './core/tc_bootstrap'
require './core/tc_modules'
require './core/tc_social_engineering'
require './core/tc_autorun'
require './core/tc_obfuscation'
require './core/tc_logger'
require './extensions/tc_xssrays'
require './extensions/tc_vnc'
require './extensions/tc_ipec_tunnel'
require './extensions/tc_hackverter'
require './extensions/tc_hooks'
require './extensions/tc_proxy'
require './extensions/tc_requester'
require './extensions/tc_event_logger'
require './tc_grep'
require './tc_filesystem'

class TS_BeefTests
  def self.suite

    suite = Test::Unit::TestSuite.new(name="BeEF Unit Test Suite")
    suite << TC_Filter.suite
    suite << TC_Loader.suite
    suite << TC_Core.suite
    suite << TC_Bootstrap.suite
    suite << TC_Api.suite
    suite << TC_Modules.suite
    suite << TC_Filesystem.suite
    suite << TC_Grep.suite
    suite << TC_SocialEngineering.suite
    suite << TC_Autorun.suite
    suite << TC_Xssrays.suite
    suite << TC_Vnc.suite
    suite << TC_Obfuscation.suite
	suite << TC_Logger.suite
    suite << TC_IpecTunnel.suite
    suite << TC_Requester.suite
    suite << TC_Proxy.suite
    suite << TC_Hackverter.suite
    suite << TC_EventLogger.suite
	suite << TC_Hooks.suite
    suite << TC_Redirector.suite

    return suite
  end
end

Test::Unit::UI::Console::TestRunner.run(TS_BeefTests)
