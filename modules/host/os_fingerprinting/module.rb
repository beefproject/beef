#
# Copyright (c) 2006-2013 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
# Uses methods described here:
# http://www.itsecuritysolutions.org/2010-03-29_fingerprinting_browsers_using_protocol_handlers/

class Os_fingerprinting < BeEF::Core::Command

  def post_execute
    content = {}
    content['windows_nt_version'] = @datastore['windows_nt_version'] if not @datastore['windows_nt_version'].nil?
    if content.empty?
      content['fail'] = 'Failed to fingerprint Windows version.'
    end
    save content
  end

end
