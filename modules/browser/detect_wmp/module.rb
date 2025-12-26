#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_wmp < BeEF::Core::Command
  def post_execute
    content = {}
    content['wmp'] = @datastore['wmp']
    save content
    BeEF::Core::Models::BrowserDetails.set(@datastore['beefhook'], 'browser.capabilities.wmp', Regexp.last_match(1)) if @datastore['results'] =~ /^wmp=(Yes|No)/
  end
end
