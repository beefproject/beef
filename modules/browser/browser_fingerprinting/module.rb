#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Uses methods described here:
# http://www.itsecuritysolutions.org/2010-03-29_fingerprinting_browsers_using_protocol_handlers/

class Browser_fingerprinting < BeEF::Core::Command

  def post_execute
    content = {}
    content['browser_type'] = @datastore['browser_type'] if not @datastore['browser_type'].nil?
    content['browser_version'] = @datastore['browser_version'] if not @datastore['browser_version'].nil?
    if content.empty?
      content['fail'] = 'Failed to fingerprint browser.'
    end
    save content
  end

end
