#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require '../common/ts_common'
require './tc_dns_rest'

class TS_DnsIntegrationTests

  def self.suite
    suite = Test::Unit::TestSuite.new(name="BeEF DNS Integration Test Suite")
    suite << TC_DnsRest.suite

    return suite
  end

end

Test::Unit::UI::Console::TestRunner.run(TS_DnsIntegrationTests)
