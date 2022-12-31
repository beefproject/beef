#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_activex < BeEF::Core::Command
  def post_execute
    content = {}
    content['activex'] = @datastore['activex']
    save content

    activex = @datastore['results'].scan(/^activex=(Yes|No)/).flatten.first
    return unless activex

    BeEF::Core::Models::BrowserDetails.set(@datastore['beefhook'], 'browser.capabilities.activex', activex)
  end
end
