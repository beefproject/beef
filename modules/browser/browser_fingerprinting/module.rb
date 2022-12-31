#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Uses methods described here:
# http://www.itsecuritysolutions.org/2010-03-29_fingerprinting_browsers_using_protocol_handlers/

class Browser_fingerprinting < BeEF::Core::Command
  def post_execute
    content = {}
    content['browser_type'] = @datastore['browser_type'] unless @datastore['browser_type'].nil?
    content['browser_version'] = @datastore['browser_version'] unless @datastore['browser_version'].nil?
    content['fail'] = 'Failed to fingerprint browser.' if content.empty?
    save content
  end
end
