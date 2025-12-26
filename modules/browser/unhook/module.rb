#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Unhook < BeEF::Core::Command
  def post_execute
    content = {}
    content['result'] = @datastore['result'] unless @datastore['result'].nil?
    save content
  end
end
