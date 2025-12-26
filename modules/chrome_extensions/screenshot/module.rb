#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Screenshot < BeEF::Core::Command
  def post_execute
    content = {}
    content['Return'] = @datastore['return']
    save content
  end
end
