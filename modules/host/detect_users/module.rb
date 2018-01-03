#
# Copyright (c) 2006-2018 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - http://beefproject.com
# See the file 'doc/COPYING' for copying permission
#

class Detect_users < BeEF::Core::Command
  def post_execute
    content = {}
    content['result'] = @datastore['result'] if not @datastore['result'].nil?
    save content
  end
end
