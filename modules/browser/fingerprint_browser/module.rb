#
# Copyright (c) 2006-2023 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Fingerprint_browser < BeEF::Core::Command
  def post_execute
    content = {}
    content['fingerprint'] = @datastore['fingerprint'] unless @datastore['fingerprint'].nil?
    content['components'] = @datastore['components'] unless @datastore['components'].nil?
    content['fail'] = 'Failed to fingerprint browser.' if content.empty?
    save content
  end
end
