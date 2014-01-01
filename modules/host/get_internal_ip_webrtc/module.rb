#
# Copyright (c) 2006-2014 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Get_internal_ip_webrtc < BeEF::Core::Command

  def post_execute
    content = {}
    content['Result'] = @datastore['result']
    save content
  end

end
