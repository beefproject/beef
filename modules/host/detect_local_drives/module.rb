#
# Copyright (c) 2006-2017 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Detect_local_drives < BeEF::Core::Command
  def post_execute
    content = {}
    content['result'] = @datastore['result'] if not @datastore['result'].nil?
    save content
  end
end
