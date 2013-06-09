#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
require '../common/ts_common'
require './extensions/tc_dns'

class TS_BeefDnsTests

  def self.suite
    suite = Test::Unit::TestSuite.new(name="BeEF DNS Unit Tests")
    suite << TC_Dns.suite

    return suite
  end

end

Test::Unit::UI::Console::TestRunner.run(TS_BeefDnsTests)
