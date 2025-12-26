#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_firebug < BeEF::Core::Command
  def post_execute
    content = {}
    content['firebug'] = @datastore['firebug'] unless @datastore['firebug'].nil?
    save content
  end
end
