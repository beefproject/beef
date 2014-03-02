#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

# Common lib for BeEF tests
require '../common/ts_common'

require 'capybara'
Capybara.run_server = false # we need to run our own BeEF server

require 'selenium/webdriver'

require './check_environment' # Basic log in and log out tests
require './tc_debug_modules' # RESTful API tests (as well as debug modules)
require './tc_login' # Basic log in and log out tests
require './tc_jools' # Basic tests for jools
                            #require './tc_dns_rest' # Basic tests for DNS RESTful API interface
require './tc_social_engineering_rest' # Basic tests for social engineering RESTful API interface

class TS_BeefIntegrationTests
  def self.suite

    suite = Test::Unit::TestSuite.new(name="BeEF Integration Test Suite")
    suite << TC_CheckEnvironment.suite
    suite << TC_login.suite
    suite << TC_DebugModules.suite
    suite << TC_Jools.suite
    #suite << TC_DnsRest.suite
    suite << TC_SocialEngineeringRest.suite

    return suite
  end
end

Test::Unit::UI::Console::TestRunner.run(TS_BeefIntegrationTests)

