#
# Copyright (c) 2006-2026 Wade Alcorn - wade@bindshell.net
# Browser Exploitation Framework (BeEF) - https://beefproject.com
# See the file 'doc/COPYING' for copying permission
#
class Detect_unsafe_activex < BeEF::Core::Command
  def post_execute
    content = {}
    content['unsafe_activex'] = @datastore['unsafe_activex']
    save content
  end
end
